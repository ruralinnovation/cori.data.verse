import Link from "next/link";
import styles from "./ContentCard.module.css";

interface ContentCardProps {
  title: string;
  description?: string;
  date?: string;
  categories?: string[];
  url: string;
  image?: string;
}

export default function ContentCard({
  title,
  description,
  date,
  categories,
  url,
}: ContentCardProps) {
  return (
    <article className={styles.card}>
      <h3 className={styles.title}>
        <Link href={url}>{title}</Link>
      </h3>
      {description && <p className={styles.description}>{description}</p>}
      <div className={styles.meta}>
        {date && (
          <span className={styles.date}>
            {new Date(date).toLocaleDateString("en-US", {
              year: "numeric",
              month: "short",
              day: "numeric",
            })}
          </span>
        )}
        {categories && categories.length > 0 && (
          <div className={styles.categories}>
            {categories.map((cat) => (
              <span key={cat} className="badge">
                {cat}
              </span>
            ))}
          </div>
        )}
      </div>
    </article>
  );
}
