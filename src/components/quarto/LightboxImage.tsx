"use client";

import { useState } from "react";
import styles from "./LightboxImage.module.css";

interface LightboxImageProps {
  src: string;
  alt?: string;
}

export default function LightboxImage({ src, alt = "" }: LightboxImageProps) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src={src}
        alt={alt}
        className={styles.image}
        onClick={() => setIsOpen(true)}
        role="button"
        tabIndex={0}
        onKeyDown={(e) => {
          if (e.key === "Enter" || e.key === " ") setIsOpen(true);
        }}
      />
      {isOpen && (
        <div
          className={styles.overlay}
          onClick={() => setIsOpen(false)}
          onKeyDown={(e) => {
            if (e.key === "Escape") setIsOpen(false);
          }}
          role="dialog"
          aria-modal="true"
          tabIndex={0}
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src={src} alt={alt} className={styles.fullImage} />
        </div>
      )}
    </>
  );
}
