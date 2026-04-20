import styles from "./CodeBlock.module.css";

interface CodeBlockProps {
  language?: string;
  children: string;
}

export default function CodeBlock({ language, children }: CodeBlockProps) {
  return (
    <div className={styles.codeBlock}>
      {language && <span className={styles.lang}>{language}</span>}
      <pre>
        <code>{children}</code>
      </pre>
    </div>
  );
}
