import styles from "./Columns.module.css";

interface ColumnsProps {
  children: React.ReactNode;
}

interface ColumnProps {
  width?: string;
  children: React.ReactNode;
}

export function Columns({ children }: ColumnsProps) {
  return <div className={styles.columns}>{children}</div>;
}

export function Column({ width, children }: ColumnProps) {
  return (
    <div className={styles.column} style={width ? { flex: `0 0 ${width}` } : undefined}>
      {children}
    </div>
  );
}
