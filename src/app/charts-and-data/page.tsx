import { getDatasets, getCharts } from "@/utils/content";
import ListingGrid from "@/components/ListingGrid";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Charts & Data",
  description: "Charts produced by rural innovation research and the datasets from which they were derived.",
};

export default function ChartsAndDataPage() {
  const datasets = getDatasets();
  const charts = getCharts();

  return (
    <div className="container">
      <div className="page-header">
        <h1>Charts &amp; Data</h1>
        <p>Charts produced by rural innovation research and the datasets from which they were derived</p>
      </div>

      {charts.length > 0 && (
        <section>
          <h2>Charts</h2>
          <ListingGrid items={charts} basePath="/charts-and-data/charts" />
        </section>
      )}

      {datasets.length > 0 && (
        <section style={{ marginBottom: "3rem" }}>
          <h2>Datasets</h2>
          <ListingGrid items={datasets} basePath="/charts-and-data/datasets" />
        </section>
      )}
    </div>
  );
}
