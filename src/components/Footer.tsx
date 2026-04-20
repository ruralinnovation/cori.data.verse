import styles from "./Footer.module.css";

export default function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className={styles.footer}>
      <div className={styles.container}>
        <div className={styles.info}>
          <p>&copy; {year} Center on Rural Innovation. All rights reserved.</p>
          <p className={styles.tagline}>
            Your hub for rural innovation data, tools, research, and analysis.
          </p>
        </div>
        <nav className={styles.nav}>
          <ul>
            <li>
              <a href="https://github.com/ruralinnovation" target="_blank" rel="noopener noreferrer">
                GitHub
              </a>
            </li>
            <li>
              <a href="https://ruralinnovation.us" target="_blank" rel="noopener noreferrer">
                CORI Website
              </a>
            </li>
          </ul>
        </nav>
      </div>
    </footer>
  );
}
