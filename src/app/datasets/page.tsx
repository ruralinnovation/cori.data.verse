import { getDatasets } from "@/utils/content";
import ListingGrid from "@/components/ListingGrid";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Datasets",
  description: "Federal and public datasets for rural innovation research",
};

export default function DatasetsPage() {
  const datasets = getDatasets();

  return (
    <div className="container">
      <div className="page-header">
        <h1>Datasets</h1>
        <p>Federal and public datasets for rural innovation research</p>
      </div>
      <ListingGrid items={datasets} basePath="/datasets" />
    </div>
  );
}
