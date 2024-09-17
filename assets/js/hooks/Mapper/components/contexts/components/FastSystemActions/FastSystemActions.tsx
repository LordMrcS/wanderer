import { useCallback, useRef } from 'react';
import { LayoutEventBlocker, WdImageSize, WdImgButton } from '@/hooks/Mapper/components/ui-kit';
import { ANOIK_ICON, DOTLAN_ICON, ZKB_ICON } from '@/hooks/Mapper/icons.ts';

import classes from './FastSystemActions.module.scss';
import clsx from 'clsx';
import { PrimeIcons } from 'primereact/api';

export interface FastSystemActionsProps {
  systemId: string;
  systemName: string;
  showEdit?: boolean;
  onOpenSettings(): void;
}

export const FastSystemActions = ({ systemId, systemName, onOpenSettings, showEdit }: FastSystemActionsProps) => {
  const ref = useRef({ systemId, systemName });
  ref.current = { systemId, systemName };

  const handleOpenZKB = useCallback(
    () => window.open(`https://zkillboard.com/system/${ref.current.systemId}`, '_blank'),
    [],
  );

  const handleOpenAnoikis = useCallback(
    () => window.open(`http://anoik.is/systems/${ref.current.systemName}`, '_blank'),
    [],
  );

  const handleOpenDotlan = useCallback(
    () => window.open(`https://evemaps.dotlan.net/system/${ref.current.systemName}`, '_blank'),
    [],
  );

  const copySystemNameToClipboard = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(ref.current.systemName);
    } catch (err) {
      console.error(err);
    }
  }, []);

  return (
    <LayoutEventBlocker className={clsx('flex px-2 gap-2 justify-between items-center h-full')}>
      <div className={clsx('flex gap-2 items-center h-full', classes.Links)}>
        <WdImgButton source={ZKB_ICON} onClick={handleOpenZKB} />
        <WdImgButton source={ANOIK_ICON} onClick={handleOpenAnoikis} />
        <WdImgButton source={DOTLAN_ICON} onClick={handleOpenDotlan} />
      </div>

      <div className="flex gap-2 items-center pl-1">
        <WdImgButton
          textSize={WdImageSize.off}
          className={PrimeIcons.COPY}
          onClick={copySystemNameToClipboard}
          tooltip={{ content: 'Copy system name' }}
        />
        {showEdit && (
          <WdImgButton
            textSize={WdImageSize.off}
            className="pi pi-pen-to-square text-base"
            onClick={onOpenSettings}
            tooltip={{ content: 'Edit system name and description' }}
          />
        )}
      </div>
    </LayoutEventBlocker>
  );
};
