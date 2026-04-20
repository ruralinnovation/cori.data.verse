import ContentCard from "./ContentCard";
import type { ContentMeta } from "@/types";

interface ListingGridProps {
  items: ContentMeta[];
  basePath: string; // e.g., "/datasets", "/packages"
}

export default function ListingGrid({ items, basePath }: ListingGridProps) {
  if (items.length === 0) {
    return <p>No items found.</p>;
  }

  return (
    <div className="listing-grid">
      {items.map((item) => (
        <ContentCard
          key={item.slug}
          title={item.title}
          description={item.description}
          date={item.date}
          categories={item.categories}
          url={`${basePath}/${item.slug}`}
          image={item.image}
        />
      ))}
    </div>
  );
}
