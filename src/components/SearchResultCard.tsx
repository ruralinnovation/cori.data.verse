import Link from "next/link";
import styles from "./SearchResultCard.module.css";

const TYPE_LABELS: Record<string, string> = {
  charts: "Chart",
  datasets: "Dataset",
  packages: "Package",
  projects: "Project",
  resources: "Resource",
};

interface SearchResultCardProps {
  type: string;
  title: string;
  description?: string | null;
  categories?: string[];
  date?: string | null;
  url: string;
}

export default function SearchResultCard({
  type,
  title,
  description,
  categories = [],
  date,
  url,
}: SearchResultCardProps) {
  return (
    <article className={styles.card}>
      <div className={styles.header}>
        <span className={`${styles.typeBadge} ${styles[type] || ""}`}>
          {TYPE_LABELS[type] || type}
        </span>
        {date && (
          <time className={styles.date} dateTime={date}>
            {new Date(date).toLocaleDateString("en-US", {
              year: "numeric",
              month: "short",
              day: "numeric",
              timeZone: "UTC",
            })}
          </time>
        )}
      </div>
      <h3 className={styles.title}>
        <Link href={url}>{title}</Link>
      </h3>
      {description && <p className={styles.description}>{description}</p>}
      {categories.length > 0 && (
        <div className={styles.categories}>
          {categories.map((cat) => (
            <span key={cat} className="badge">
              {cat}
            </span>
          ))}
        </div>
      )}
    </article>
  );
}
