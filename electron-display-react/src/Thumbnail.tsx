import React from 'react';
import './Thumbnail.css';

export type ThumbnailProps = {
    index: number,
    onClick: (event: React.MouseEvent<HTMLDivElement, MouseEvent>) => void,
    thumbnailURL: string | null,
}

const Thumbnail = ({index, onClick, thumbnailURL} : ThumbnailProps) => {
  return (
    <div className="Thumbnail" onClick={onClick}>
      <p>Plot {index}</p>
      {thumbnailURL && <img src={thumbnailURL} className="thumbnail-image" alt="" />}
    </div>
  );
}

export default Thumbnail;
