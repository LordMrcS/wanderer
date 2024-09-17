defmodule WandererApp.Character do
  @moduledoc false

  require Logger

  @read_character_wallet_scope "esi-wallet.read_character_wallet.v1"
  @read_corp_wallet_scope "esi-wallet.read_corporation_wallets.v1"

  def get_character(character_id) do
    case Cachex.get(:character_cache, character_id) do
      {:ok, nil} ->
        case WandererApp.Api.Character.by_id(character_id) do
          {:ok, character} ->
            Cachex.put(:character_cache, character_id, character)
            {:ok, character}

          _ ->
            {:error, :not_found}
        end

      {:ok, character} ->
        {:ok, character}
    end
  end

  def get_character!(character_id) do
    case get_character(character_id) do
      {:ok, character} ->
        character

      _ ->
        Logger.error("Failed to get character #{character_id}")
        nil
    end
  end

  def get_character_eve_ids!(character_ids),
    do:
      character_ids
      |> Enum.map(fn character_id ->
        character_id |> get_character!() |> Map.get(:eve_id)
      end)

  def update_character(character_id, character_update) do
    Cachex.get_and_update(:character_cache, character_id, fn character ->
      case character do
        nil ->
          case WandererApp.Api.Character.by_id(character_id) do
            {:ok, character} ->
              {:commit, Map.merge(character, character_update)}

            _ ->
              {:ignore, nil}
          end

        _ ->
          {:commit, Map.merge(character, character_update)}
      end
    end)
  end

  def get_character_state(character_id) do
    case Cachex.get(:character_state_cache, character_id) do
      {:ok, nil} ->
        character_state = WandererApp.Character.Tracker.init(character_id: character_id)
        Cachex.put(:character_state_cache, character_id, character_state)
        {:ok, character_state}

      {:ok, character_state} ->
        {:ok, character_state}
    end
  end

  def update_character_state(character_id, character_state_update) do
    Cachex.get_and_update(:character_state_cache, character_id, fn character_state ->
      case character_state do
        nil ->
          new_state = WandererApp.Character.Tracker.init(character_id: character_id)
          {:commit, Map.merge(new_state, character_state_update)}

        _ ->
          {:commit, Map.merge(character_state, character_state_update)}
      end
    end)
  end

  def delete_character_state(character_id) do
    Cachex.del(:character_state_cache, character_id)
  end

  def set_autopilot_waypoint(
        character_id,
        destination_id,
        opts
      ) do
    {:ok, %{access_token: access_token}} = WandererApp.Character.get_character(character_id)

    WandererApp.Esi.set_autopilot_waypoint(
      opts[:add_to_beginning],
      opts[:clear_other_waypoints],
      destination_id,
      access_token: access_token
    )

    :ok
  end

  def search(character_id, opts \\ []) do
    {:ok, %{access_token: access_token, eve_id: eve_id} = _character} =
      get_character(character_id)

    case WandererApp.Esi.search(eve_id |> String.to_integer(),
           access_token: access_token,
           character_id: character_id,
           refresh_token?: true,
           params: opts[:params]
         ) do
      {:ok, result} ->
        {:ok, result |> _prepare_search_results()}

      {:error, error} ->
        Logger.warning("#{__MODULE__} failed search: #{inspect(error)}")
        {:ok, []}
    end
  end

  def can_track_wallet?(%{scopes: scopes} = _character) when not is_nil(scopes) do
    scopes |> String.split(" ") |> Enum.member?(@read_character_wallet_scope)
  end

  def can_track_wallet?(_), do: false

  def can_track_corp_wallet?(%{scopes: scopes} = _character) when not is_nil(scopes) do
    scopes |> String.split(" ") |> Enum.member?(@read_corp_wallet_scope)
  end

  def can_track_corp_wallet?(_), do: false

  def get_ship(%{ship: ship_type_id, ship_name: ship_name} = _character)
      when not is_nil(ship_type_id) and is_integer(ship_type_id) do
    ship_type_id
    |> WandererApp.CachedInfo.get_ship_type()
    |> case do
      {:ok, ship_type_info} when not is_nil(ship_type_info) ->
        %{ship_type_id: ship_type_id, ship_name: ship_name, ship_type_info: ship_type_info}

      _ ->
        %{ship_type_id: ship_type_id, ship_name: ship_name, ship_type_info: %{}}
    end
  end

  def get_ship(%{ship_name: ship_name} = _character) when is_binary(ship_name),
    do: %{ship_name: ship_name, ship_type_info: %{}}

  def get_ship(_),
    do: %{ship_name: nil, ship_type_info: %{}}

  def get_location(
        %{solar_system_id: solar_system_id, structure_id: structure_id} =
          _character
      ) do
    case WandererApp.CachedInfo.get_system_static_info(solar_system_id) do
      {:ok, system_static_info} when not is_nil(system_static_info) ->
        %{
          solar_system_id: solar_system_id,
          structure_id: structure_id,
          solar_system_info: system_static_info
        }

      _ ->
        %{
          solar_system_id: solar_system_id,
          structure_id: structure_id,
          solar_system_info: %{}
        }
    end
  end

  defp _prepare_search_results(result) do
    {:ok, characters} =
      _load_eve_info(Map.get(result, "character"), :get_character_info, &_map_character_info/1)

    {:ok, corporations} =
      _load_eve_info(
        Map.get(result, "corporation"),
        :get_corporation_info,
        &_map_corporation_info/1
      )

    {:ok, alliances} =
      _load_eve_info(Map.get(result, "alliance"), :get_alliance_info, &_map_alliance_info/1)

    [[characters | corporations] | alliances] |> List.flatten()
  end

  defp _load_eve_info(nil, _, _), do: {:ok, []}

  defp _load_eve_info([], _, _), do: {:ok, []}

  defp _load_eve_info(eve_ids, method, map_function),
    do:
      {:ok,
       Enum.map(eve_ids, fn eve_id ->
         Task.async(fn -> apply(WandererApp.Esi.ApiClient, method, [eve_id]) end)
       end)
       # 145000 == Timeout in milliseconds
       |> Enum.map(fn task -> Task.await(task, 145_000) end)
       |> Enum.map(fn {:ok, result} -> map_function.(result) end)}

  defp _map_alliance_info(info) do
    %{
      label: info["name"],
      value: info["eve_id"] |> to_string(),
      alliance: true
    }
  end

  defp _map_character_info(info) do
    %{
      label: info["name"],
      value: info["eve_id"] |> to_string(),
      character: true
    }
  end

  defp _map_corporation_info(info) do
    %{
      label: info["name"],
      value: info["eve_id"] |> to_string(),
      corporation: true
    }
  end
end
