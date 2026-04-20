"use client";

import { useState } from "react";
import styles from "./PanelTabset.module.css";

interface Tab {
  label: string;
  content: React.ReactNode;
}

interface PanelTabsetProps {
  tabs: Tab[];
}

export default function PanelTabset({ tabs }: PanelTabsetProps) {
  const [activeIndex, setActiveIndex] = useState(0);

  if (tabs.length === 0) return null;

  return (
    <div className={styles.tabset}>
      <div className={styles.tabList} role="tablist">
        {tabs.map((tab, i) => (
          <button
            key={i}
            role="tab"
            aria-selected={i === activeIndex}
            className={`${styles.tab} ${i === activeIndex ? styles.active : ""}`}
            onClick={() => setActiveIndex(i)}
          >
            {tab.label}
          </button>
        ))}
      </div>
      <div className={styles.tabPanel} role="tabpanel">
        {tabs[activeIndex]?.content}
      </div>
    </div>
  );
}
