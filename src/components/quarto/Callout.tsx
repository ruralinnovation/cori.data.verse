import styles from "./Callout.module.css";

type CalloutType = "note" | "tip" | "warning" | "important";

interface CalloutProps {
  type: CalloutType;
  children: React.ReactNode;
}

const ICONS: Record<CalloutType, string> = {
  note: "i",
  tip: "!",
  warning: "!",
  important: "!",
};

const LABELS: Record<CalloutType, string> = {
  note: "Note",
  tip: "Tip",
  warning: "Warning",
  important: "Important",
};

export default function Callout({ type, children }: CalloutProps) {
  return (
    <div className={`${styles.callout} ${styles[type]}`}>
      <div className={styles.header}>
        <span className={styles.icon}>{ICONS[type]}</span>
        <span className={styles.label}>{LABELS[type]}</span>
      </div>
      <div className={styles.body}>{children}</div>
    </div>
  );
}
