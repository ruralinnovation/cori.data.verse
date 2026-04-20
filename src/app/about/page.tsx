import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "About",
  description: "About the Rural Insights Dataverse and the CORI MDA team",
};

export default function AboutPage() {
  return (
    <div className="container" style={{ padding: "2rem 0" }}>
      <h1>About Rural Insights Dataverse</h1>
      <p>
        Rural Insights Dataverse is the data hub for the Mapping &amp; Data Analytics
        (MDA) team at the{" "}
        <a href="https://ruralinnovation.us" target="_blank" rel="noopener noreferrer">
          Center on Rural Innovation (CORI)
        </a>
        .
      </p>
      <p>
        We curate federal and public datasets, develop open-source R packages,
        and conduct research projects focused on rural economic development,
        broadband access, and community well-being.
      </p>

      <h2>What We Do</h2>
      <ul>
        <li>
          Maintain curated datasets covering employment, demographics, broadband
          access, business statistics, and economic indicators
        </li>
        <li>
          Build open-source R packages for accessing and analyzing rural data
        </li>
        <li>
          Conduct research projects combining multiple data sources to
          understand rural trends
        </li>
        <li>
          Share analyses and insights through blog posts and data stories
        </li>
      </ul>

      <h2>Contact</h2>
      <p>
        Find us on{" "}
        <a href="https://github.com/ruralinnovation" target="_blank" rel="noopener noreferrer">
          GitHub
        </a>{" "}
        or visit the{" "}
        <a href="https://ruralinnovation.us" target="_blank" rel="noopener noreferrer">
          CORI website
        </a>
        .
      </p>
    </div>
  );
}
