import React from 'react';
import './Thumbnail.css';

export type ThumbnailProps = {
    index: number,
    onClick: (event: React.MouseEvent<HTMLDivElement, MouseEvent>) => void,
}

const Thumbnail = ({index, onClick} : ThumbnailProps) => {
  return (
    <div className="Thumbnail" onClick={onClick}>
      Plot {index}
    </div>
  );
}

export default Thumbnail;
