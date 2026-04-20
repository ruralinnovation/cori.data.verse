import { getDatasets, getCharts } from "@/utils/content";
import ListingGrid from "@/components/ListingGrid";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Charts & Data",
  description: "Federal datasets and interactive charts for rural innovation research",
};

export default function ChartsAndDataPage() {
  const datasets = getDatasets();
  const charts = getCharts();

  return (
    <div className="container">
      <div className="page-header">
        <h1>Charts &amp; Data</h1>
        <p>Federal datasets and interactive charts for rural innovation research</p>
      </div>

      {datasets.length > 0 && (
        <section style={{ marginBottom: "3rem" }}>
          <h2>Datasets</h2>
          <ListingGrid items={datasets} basePath="/charts-and-data/datasets" />
        </section>
      )}

      {charts.length > 0 && (
        <section>
          <h2>Charts</h2>
          <ListingGrid items={charts} basePath="/charts-and-data/charts" />
        </section>
      )}
    </div>
  );
}
