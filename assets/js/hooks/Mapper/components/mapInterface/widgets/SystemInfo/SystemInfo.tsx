import { Widget } from '@/hooks/Mapper/components/mapInterface/components';
import { useMapRootState } from '@/hooks/Mapper/mapRootProvider';
import { LayoutEventBlocker, SystemView, WdImgButton } from '@/hooks/Mapper/components/ui-kit';
import { SystemInfoContent } from './SystemInfoContent';
import { PrimeIcons } from 'primereact/api';
import { useState, useCallback } from 'react';
import { SystemSettingsDialog } from '@/hooks/Mapper/components/mapInterface/components/SystemSettingsDialog/SystemSettingsDialog.tsx';
import { getSystemById } from '@/hooks/Mapper/helpers';
import { ANOIK_ICON, DOTLAN_ICON, ZKB_ICON } from '@/hooks/Mapper/icons';

export const SystemInfo = () => {
  const [visible, setVisible] = useState(false);

  const {
    data: { selectedSystems, systems },
  } = useMapRootState();

  const [systemId] = selectedSystems;

  const sys = getSystemById(systems, systemId)!;
  const { solar_system_name: solarSystemName } = sys?.system_static_info || {};

  const isNotSelectedSystem = selectedSystems.length !== 1;

  const copySystemNameToClipboard = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(solarSystemName);
    } catch (err) {
      console.error(err);
    }
  }, [solarSystemName]);

  return (
    <Widget
      label={
        !isNotSelectedSystem && (
          <div className="flex justify-between items-center text-xs h-full w-full">
            <div className="flex gap-1">
              <SystemView systemId={systemId} className="select-none text-center" hideRegion />
              <LayoutEventBlocker className="flex gap-1 items-center">
                <WdImgButton className={PrimeIcons.COPY} onClick={copySystemNameToClipboard} />
                <WdImgButton
                  className="pi pi-pen-to-square"
                  onClick={() => setVisible(true)}
                  tooltip={{ content: 'Edit system name and description' }}
                />
              </LayoutEventBlocker>
            </div>

            <LayoutEventBlocker className="flex gap-1 items-center">
              <a href={`https://zkillboard.com/system/${systemId}`} rel="noreferrer" target="_blank">
                <img src={ZKB_ICON} width="14" height="14" className="external-icon" />
              </a>
              <a href={`http://anoik.is/systems/${solarSystemName}`} rel="noreferrer" target="_blank">
                <img src={ANOIK_ICON} width="14" height="14" className="external-icon" />
              </a>
              <a href={`https://evemaps.dotlan.net/system/${solarSystemName}`} rel="noreferrer" target="_blank">
                <img src={DOTLAN_ICON} alt="" width="14" height="14" className="external-icon" />
              </a>
            </LayoutEventBlocker>
          </div>
        )
      }
    >
      {isNotSelectedSystem ? (
        <div className="w-full h-full flex justify-center items-center select-none text-center text-stone-400/80 text-sm">
          System is not selected
        </div>
      ) : (
        <SystemInfoContent systemId={systemId} onEditClick={() => setVisible(true)} />
      )}

      {visible && <SystemSettingsDialog systemId={systemId} visible setVisible={setVisible} />}
    </Widget>
  );
};
