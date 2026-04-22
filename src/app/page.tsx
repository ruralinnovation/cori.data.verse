import Link from "next/link";

export default function HomePage() {
  return (
    <>
      <div className="hero">
        <div className="container">
          <h1>Welcome to the Rural Dataverse</h1>
          <p className="hero-description">
            A universe of rural innovation data, tools, research, and analysis from the Center on Rural Innovation (CORI).
          </p>
          <div className="hero-actions">
            <Link href="/charts-and-data" className="btn btn-primary">
              Charts &amp; Data
            </Link>
          </div>
        </div>
      </div>

      <section style={{ padding: "3rem 0" }}>
        <div className="container">
          <h2>What You&apos;ll Find Here</h2>
          <div className="listing-grid">
            <div className="card" style={{ padding: "1.5rem", border: "1px solid var(--color-border)", borderRadius: "8px" }}>
              <h3>Charts &amp; Data</h3>
              <p>
                Federal and public datasets and interactive charts covering
                employment, demographics, broadband access, business statistics,
                and economic indicators for rural communities.
              </p>
              <Link href="/charts-and-data" className="btn btn-link">
                Browse Charts &amp; Data &rarr;
              </Link>
            </div>
            <div className="card" style={{ padding: "1.5rem", border: "1px solid var(--color-border)", borderRadius: "8px" }}>
              <h3>Projects</h3>
              <p>
                Research projects and analyses combining multiple datasets to
                understand rural economic trends, broadband adoption, and
                community development.
              </p>
              <Link href="/projects" className="btn btn-link">
                Explore Projects &rarr;
              </Link>
            </div>
            <div className="card" style={{ padding: "1.5rem", border: "1px solid var(--color-border)", borderRadius: "8px" }}>
              <h3>R Packages</h3>
              <p>
                Open-source R packages for accessing rural data, including tools
                for rural definitions, FCC broadband data, and business dynamics
                statistics.
              </p>
              <Link href="/packages" className="btn btn-link">
                View Packages &rarr;
              </Link>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
