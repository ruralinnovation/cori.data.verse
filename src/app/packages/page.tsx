import { getPackages } from "@/utils/content";
import ListingGrid from "@/components/ListingGrid";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "R Packages",
  description: "Open-source R packages for accessing rural data",
};

export default function PackagesPage() {
  const packages = getPackages();

  return (
    <div className="container">
      <div className="page-header">
        <h1>R Packages</h1>
        <p>Open-source R packages for accessing rural data</p>
      </div>
      <ListingGrid items={packages} basePath="/packages" />
    </div>
  );
}
