# Rural Context Copy — Working Draft
## "What This Data Tells Us About Rural" sections for all content types

This document is a working draft of the interpretive copy for package, dataset, and
project pages. Sources: CORI Economic Development Tool metric descriptions, project
findings across proj_emporia, data-rural-economic-outlook, proj_capitalone,
proj_community_profiles, proj_ecmc, proj_nsf, proj_rwjf_seed_of_change,
proj_rwjf_soc_2_public_funding, data-calix-impact-tool.

**Status legend:**
- ✅ Strong evidence — ready to draft
- 🔶 Partial evidence — draft with caveats
- ❌ TBD — insufficient grounding, leave placeholder

---

# PACKAGES

---

## cori.data (umbrella)

✅ Strong evidence

Rural economies are diverse, complex, and deeply shaped by the assets and advantages
they have accumulated over time — natural resources, agricultural land, industrial
infrastructure, geographic position, community institutions, and workforce traditions.
Some rural communities are thriving, leveraging those assets in new ways as remote work,
entrepreneurship, and targeted investment open new pathways. Others are navigating
structural transitions as legacy industries shift. What they share is a foundation of
real assets whose value in the modern economy depends on the conditions surrounding them.

Understanding which assets a community holds, how those assets connect to current
economic conditions, and what they might support going forward requires data that spans
multiple dimensions simultaneously. Employment trends read alongside business formation
rates, population dynamics, broadband coverage, and sector composition tell a richer
story than any single source alone. Across CORI's research, communities with strong
asset bases across multiple dimensions tend to show more resilient economic trajectories
than those concentrated in a single advantage — and human capital, quality of life, and
the capacity to retain and attract working-age residents consistently emerge as important
complements to physical infrastructure.

The ecosystem exists because these questions require data that is consistent, joinable,
and contextualized for rural analysis — and because the methodological decisions that
make cross-source rural analysis tractable (which rural definition to apply, how to
weight aggregations across counties of very different sizes, which sector taxonomy to
use) are embedded in the packages rather than left to each researcher to reinvent.

---

## cori.data.qcew

✅ Strong evidence

Employment is the most fundamental indicator of a local economy's health — and one of
the most easily misread in a rural context. Aggregate employment counts can grow while
wages stagnate, or decline while productivity rises. In CORI's community research, many
rural counties show GDP per capita growth alongside employment that has not recovered to
prior peaks — a pattern that reflects a smaller, more productive workforce rather than
a stagnant one. The headline number and the underlying story can point in different
directions.

What the QCEW data adds beyond simple employment counts is sector composition. CORI's
three-way classification — tradable goods, tradable services, and local services — is
particularly useful for rural analysis. Local services (retail, healthcare, food service)
meet local demand and scale with population; they are essential to community function
but do not drive wage growth or export earnings. Tradable goods and services —
manufacturing, agriculture, finance, tech, professional services — bring external income
into a community and shape its long-run wage trajectory. Rural counties with strong
tradable sectors reflect economies whose historical asset base remains economically
active. Those shifting toward tradable services are often communities building new
competitive advantages alongside inherited ones.

Industry concentration is a structural feature of many rural economies, reflecting the
historic dominance of particular assets — a major employer, an agricultural commodity,
a natural resource. Concentration can be a strength (scale, specialization, deep
supply chains) and a source of vulnerability (exposure if that industry contracts). The
QCEW data makes this composition visible at the county level and trackable over time,
supporting both the identification of strengths and the analysis of diversification
opportunities.

Average annual pay reflects both the composition of employment and wages within sectors.
Understanding the wage structure of a rural economy — not just its size — is essential
for reading its trajectory and its capacity to retain talent.

---

## cori.data.bds

✅ Strong evidence

Business dynamics data captures what employment data misses: the churning process
beneath aggregate counts. A county can hold steady employment while simultaneously
losing established firms and gaining new ones — or vice versa. Entry and exit rates,
job creation by firm age, and establishment counts together describe whether a rural
economy is renewing itself or sustaining on its existing institutional base.

Young firms — those five years old or less — create a disproportionate share of net new
jobs in the U.S. economy. Rural communities with active entrepreneurial ecosystems show
this pattern clearly, and CORI's community research documents meaningful business
formation growth in communities that have invested in their entrepreneurial
infrastructure. Converting new business formation into employment growth takes time,
capital, and ecosystem depth — the BDS data supports tracking that progression over
multiple years rather than treating any single year as definitive.

High exit rates in isolation can look like distress. But exit rates interpreted alongside
entry rates tell a more nuanced story: dynamic economies churn. A community with both
high entry and high exit rates may be more economically active than one with low rates
of both. The BDS data supports this kind of comparative reading across rural county
types and over time.

Industry concentration at the county level reveals the degree to which a rural economy's
employment base is anchored in a narrow set of sectors — often a direct reflection of
the community's core assets. Understanding that concentration is the starting point for
any economic development strategy, whether the goal is to deepen existing strengths or
to build complementary capacity alongside them.

---

## cori.data.bfs

🔶 Partial evidence

Business applications — measured as Employer Identification Number (EIN) filings — are
a leading indicator of entrepreneurial activity. They signal intent before establishment,
and as such are one of the earliest observable markers of entrepreneurial momentum in a
local economy. CORI's research across community profiles found application rates tracking
closely with later establishment growth in communities that had invested in their
entrepreneurial support infrastructure.

Rural business application rates surged during and after the pandemic, reflecting both
genuine entrepreneurial opportunity — remote workers and returnees starting businesses
in communities they chose — and structural adaptation as rural communities responded to
changing economic conditions. This responsiveness is itself evidence of rural economic
resilience: the same assets that anchored legacy industries — affordable space, community
networks, lower operating costs — create conditions where new business formation can
take hold.

Business applications are best interpreted as a leading indicator of future establishment
counts rather than a measure of current economic strength. Not all applications convert
to employer businesses, and the conversion rate varies by community conditions, industry,
and access to capital and support. Reading application trends alongside employment and
wage data gives the fullest picture of whether entrepreneurial momentum is translating
into durable economic change.

---

## cori.data.bps

🔶 Partial evidence

Housing supply is a foundational asset for rural economic development — and in many
communities, a binding constraint on growth strategies that are otherwise well-designed.
CORI's place-based community research has found communities with genuine competitive
assets — skilled institutions, entrepreneurial infrastructure, strong broadband — where
housing shortfall functions as a ceiling on everything else. Workers cannot relocate to
communities where housing is unavailable or unaffordable, and population retention
becomes harder when housing stock does not keep pace with demand.

Building permit data captures the rate at which housing supply is responding to
conditions on the ground. An increase in permit activity indicates that supply is growing
in response to demand, and that local regulatory conditions allow it. Where permit
activity lags population or employment growth, the data surfaces a constraint that
deserves attention alongside other economic development investments.

**TBD:** Broader rural patterns across building permit data — specific rural vs.
nonrural comparisons not yet grounded in CORI research. Revisit after reviewing
data-rural-economic-outlook housing section.

---

## cori.data.fcc

✅ Strong evidence

Broadband infrastructure is a foundational asset for rural participation in the modern
economy — enabling remote work, business formation, telehealth, and education in
communities that geography once isolated from these opportunities. The FCC National
Broadband Map (NBM) provides the most current county-level picture of where
infrastructure exists and at what speeds, making it possible to track the closing of
the rural broadband gap over time.

The more complex story is what happens after infrastructure arrives. CORI's research
consistently finds a gap between availability and adoption across rural communities —
even communities with strong fiber coverage often show remote work adoption rates well
below state averages. Infrastructure is necessary but activating it requires
complementary conditions: employer policies, workforce awareness, device access,
affordability, and the presence of job types that can be performed remotely.

CORI's research surfaces an additional nuance: higher broadband coverage is associated
with lower establishment entry rates in some rural contexts. One interpretation is that
broadband expands the labor market options available to rural workers — enabling access
to remote employment nationally — which reduces the economic pressure to start local
businesses. This does not make broadband investment misguided; it means broadband's
economic effects operate through multiple channels simultaneously, some of which work
in different directions.

Research shows that high-speed internet improves economic outcomes in rural communities
through increased business activity and broader economic development measures including
productivity, jobs, and income. The NBM data makes it possible to track where rural
broadband investment is occurring, where gaps persist, and how coverage has evolved
over time.

---

## cori.data.pep

✅ Strong evidence

Population change reflects how people are responding to conditions on the ground —
economic opportunity, quality of life, housing access, community character. It is often
treated as a simple headline indicator, but the headline number obscures as much as it
reveals. A community losing population through out-migration while also seeing natural
increase is in a different situation than one losing population through both channels
simultaneously. A community attracting working-age in-migrants is building differently
than one growing through retiree in-migration or international immigration, each of
which carries different implications for the labor market, consumer base, and service
demands.

The Population Estimates Program data supports exactly this kind of disaggregated
reading. Components of change — births, deaths, domestic migration, international
migration — allow researchers and community leaders to understand *why* population is
moving, not just whether it is. CORI's community analysis found that net population
numbers frequently masked offsetting flows: communities experiencing apparent stability
were in some cases losing working-age residents while gaining older adults — a pattern
with significant implications for workforce, entrepreneurship, and long-run fiscal
capacity.

The in-migration of older adults is an underrecognized asset for rural communities.
Research suggests that individuals migrating to rural areas later in life bring human,
financial, and business capital — their experience and resources can stimulate local
economies, support entrepreneurship, and deepen community networks. Population dynamics,
read through the full components of change rather than the net headline, reveal which
assets a community is gaining and which it is at risk of losing.

---

## cori.data.hu

❌ TBD

Housing units data tracks the total stock of housing at the county level over time.
Combined with population and building permits data, it supports analysis of housing
availability and supply-demand dynamics.

**TBD:** Insufficient grounding in current CORI research to write a substantive
interpretive section. Revisit after reviewing data-erc and data_cori_econ_dev_pipeline
for housing units usage patterns.

---

## ruraldefinitions

✅ Strong evidence

"Rural" is not a single definition. The federal government uses multiple classification
systems — CBSA metropolitan/micropolitan delineations, USDA Rural-Urban Continuum Codes,
NCHS Urban-Rural Classification, USDA Urban Influence Codes — each designed for
different purposes and drawing the rural/nonrural boundary in different places. A county
classified as rural under one system may not be under another. Researchers who select
a definition without considering what it measures risk drawing conclusions that reflect
the classification rather than the underlying reality.

CORI's standard for county-level economic analysis is the CBSA-based definition (OMB
metropolitan/micropolitan delineations), which classifies counties as rural if they
fall outside a Core-Based Statistical Area. This definition is appropriate for most
economic analysis because it reflects labor market integration — counties inside CBSAs
have economic ties to urban cores that counties outside do not. It is not the only
valid choice: USDA's Rural-Urban Continuum Codes offer a gradient rather than a binary,
capturing the range from completely rural to adjacent to large metro; the NCHS
classification is designed specifically for health research contexts.

The choice of definition is a methodological decision with real consequences. CORI's
research documents patterns that differ between rural and nonrural counties — in
employment composition, broadband coverage, business formation, and capital access —
but the magnitude and the set of counties involved vary depending on which definition
is applied. Making that choice explicit and defensible is part of credible rural
analysis.

One additional dimension the data makes visible: the misconception that rural communities
are homogeneously white renders people of color invisible in data, policy, and practice.
Rural communities include significant Black, Hispanic, Native American, and Asian
populations whose experiences and economic assets are not captured in analyses that
treat rural as a monolithic category. Rural classifications are most useful when paired
with demographic data, not used as a substitute for it.

---

# DATASETS

---

## qcew-employment-wages

✅ Strong evidence

The Quarterly Census of Employment and Wages is among the most complete pictures of
local labor market conditions available at the county level. Because it is derived from
unemployment insurance records rather than a survey, it covers roughly 95% of all
employment — providing a near-census of covered jobs, wages, and their industry
distribution rather than an estimate subject to sampling error. For rural analysis,
this matters: survey-based employment estimates can be unreliable in small counties
where sample sizes are thin, and the QCEW's administrative foundation makes it more
trustworthy in exactly the geographies where other sources struggle.

What the data reveals about rural communities is not a single pattern but a range of
conditions. Some rural counties show employment concentrated in a small number of
industries — reflecting a heritage of specialization in agriculture, natural resource
extraction, or manufacturing — and are building toward greater sectoral diversity. Others
show more distributed employment across sectors, often in communities that have developed
institutional anchors like universities, medical centers, or public-sector employment
that create a more diversified base. Both patterns are visible in the data, and both
have implications for wage trajectories, resilience to economic shocks, and capacity
for growth.

Wages in rural communities tend to be lower on average than in metro areas, but the
gap varies significantly by sector. In tradable goods and services — the sectors that
bring external income into a community — rural wages can be competitive. The wage
gap is most pronounced in tradable services, which reflects a structural opportunity:
communities that can grow their share of knowledge-economy employment tend to see wage
growth that outpaces their peers.

---

## fcc-broadband

✅ Strong evidence

The FCC National Broadband Map represents the most granular and current public dataset
on broadband infrastructure availability in the United States. For rural communities,
it documents both how far the rural broadband gap has closed in recent years and where
meaningful gaps remain. Coverage at speeds sufficient for remote work (100/20 Mbps) and
fiber deployment are the metrics most relevant for economic development analysis;
together they describe the quality of a community's digital infrastructure, not just
its presence.

The data reflects infrastructure availability — what is built and where — not whether
households are connected or what speeds they actually experience. This distinction
matters for rural analysis: communities with strong coverage on paper can still face
adoption challenges driven by affordability, device access, or awareness. The NBM data
is the starting point for understanding a community's digital infrastructure position,
but adoption and usage data from the ACS are needed to understand whether that
infrastructure is translating into economic participation.

Broadband coverage has improved substantially in rural communities since the FCC began
the NBM data collection in 2022, driven by federal infrastructure investment programs.
The data supports tracking that progress over time and identifying where gaps persist —
particularly in the most remote and historically underserved communities whose economic
development depends on closing the infrastructure gap.

---

## census-bds

✅ Strong evidence

The Business Dynamics Statistics provide a window into the entrepreneurial vitality of
local economies that employment headcounts alone cannot offer. By tracking establishment
entry, exit, and survival alongside job creation and destruction at the county level,
the BDS reveals whether a community's business base is renewing itself, contracting, or
consolidating — dynamics that have significant implications for long-run economic
resilience.

Rural communities tend to have smaller and more concentrated business ecosystems than
their metro counterparts, which makes the BDS particularly informative. In communities
where a small number of establishments account for a large share of employment, business
exit can be consequential in ways that aggregate county-level employment data absorbs
only with a lag. The BDS makes the churning process beneath the headline visible: a
community holding steady employment while losing established firms and gaining new ones
is in a fundamentally different position than one where the same employers have
persisted for decades.

Young firms — those less than five years old — are responsible for a disproportionate
share of net new job creation nationally, and this pattern holds in rural communities
as well. Tracking the entry and early survival of young firms over time gives
researchers and community leaders a leading indicator of where entrepreneurial momentum
is building and where it may be stalling. CORI's research has found that business
formation and employment growth are not always tightly coupled in the short run — new
businesses take time to scale — making multi-year trend analysis more informative than
any single year snapshot.

---

## census-population-estimates

✅ Strong evidence

Population estimates are among the most-used inputs to rural economic analysis, but
their value lies in the components of change rather than the headline net figure. A
community growing at 0.5% per year through natural increase and retiree in-migration
is building a very different demographic and economic future than one growing at the
same rate through working-age in-migration. The Population Estimates Program provides
the annual county-level components — births, deaths, domestic net migration,
international net migration — that make this disaggregation possible.

For rural communities, population trends reflect the cumulative effect of economic
conditions, quality of life, and community capacity over time. Out-migration of
working-age residents is a persistent pattern in many rural counties and is not always
reversed by improvements in economic indicators alone — CORI's research suggests that
non-economic factors including schools, social networks, amenities, and community
character are part of the calculus. Understanding which demographic flows are driving
population change helps identify which levers are most likely to influence the trajectory.

The in-migration of older adults is an asset that rural communities sometimes
underestimate. Retirees and pre-retirement migrants bring financial capital, accumulated
skills, and often entrepreneurial experience. Their arrival can support local service
demand and stimulate small business formation in ways that working-age migration data
alone would not predict.

---

## usda-county-typology

🔶 Partial evidence

The USDA Economic Research Service County Typology codes classify rural counties by
their primary economic dependence — farming, mining, manufacturing, federal/state
government, recreation — as well as by policy-relevant characteristics including
persistent poverty, population loss, retirement destination, and low employment. These
classifications provide a structured vocabulary for the heterogeneity that aggregate
rural/nonrural definitions obscure.

Understanding which typology a community falls into contextualizes what the economic
data shows. A farming-dependent county with declining employment is experiencing a
different challenge than a manufacturing-dependent county with the same trend. A
recreation-destination county with population growth is building on different assets
than a retirement-destination county with similar demographics. The typology codes
allow researchers to build peer comparisons across communities with similar structural
starting points rather than treating all rural counties as equivalent.

**TBD:** Specific findings from CORI research using typology codes — revisit after
reviewing data-rural-economic-outlook and community profiles for typology usage.

---

## american-community-survey

🔶 Partial evidence

The American Community Survey provides the broadest cross-section of socioeconomic
conditions at the county level — covering educational attainment, income, employment
by occupation, housing costs, remote work, self-employment, race and ethnicity, and
dozens of additional measures. It is the primary source for the demographic and
household-level context that labor market and business data alone cannot supply.

For rural analysis, the ACS is particularly valuable for measures that reflect the
quality and accessibility of economic opportunity, not just its quantity. Educational
attainment shapes the workforce available to attract and grow businesses. Self-employment
rates reflect both opportunity entrepreneurship and necessity entrepreneurship, and the
distinction between the two requires reading the ACS alongside employment and wage data.
Remote work adoption rates reveal whether broadband infrastructure is translating into
actual workforce flexibility. These are dimensions of economic conditions that QCEW and
BDS cannot see.

The ACS does not have a CORI R package — and for good reason. The `tidycensus` package
already provides excellent, well-maintained access to ACS data with a clean interface
for R users. The Data Verse surfaces the ACS as a key rural data resource not because
CORI has repackaged it, but because understanding what the ACS measures and how to use
it well in a rural context is part of what this resource is for. This is the hub model:
not every resource needs a CORI wrapper; some need context, framing, and connection to
the broader ecosystem of rural data assets.

**TBD:** More specific rural findings grounded in CORI ACS research — the data appears
widely across CORI projects but specific rural interpretive findings are distributed
across many analyses rather than consolidated. Revisit after data-rural-economic-outlook
and community profiles deep dive.

---

## tiger-line

✅ Strong evidence

The U.S. Census Bureau's TIGER/Line shapefiles are the standard geographic reference
for U.S. county, place, tract, and block boundaries. For anyone doing rural data
analysis, understanding the geographic framework is not optional — the choice of
geographic unit shapes every analysis that follows.

The county is the standard unit for most rural economic analysis, and for good reason.
Counties are the smallest geography for which most federal economic datasets (QCEW, BDS,
BPS, BFS, PEP) are consistently available over time. They correspond roughly to
meaningful labor market areas in rural contexts — people live, work, and access services
within a county in ways that don't always hold at finer geographies. And county FIPS
codes serve as the universal join key across nearly every data source in this ecosystem.

But counties are not the only relevant geography, and for some questions they are the
wrong one. Census tracts capture neighborhood-level variation within counties — relevant
for housing, demographics, and broadband analysis at finer resolution. Census places
(cities, towns, unincorporated communities) reflect the jurisdictions that rural
residents actually identify with and that local governments often serve. Understanding
when to use which geography — and what is and isn't available at each level — is a
foundational skill for rural data analysis.

For spatial analysis, TIGER/Line shapefiles are available directly from the Census
Bureau and integrate cleanly with R's `sf` package. The `tidycensus` package also
provides a convenient `geometry = TRUE` option that returns ACS and decennial Census
data with county or tract boundaries attached — making it the most practical entry
point for most rural mapping workflows.

---

## census-bfs

🔶 Partial evidence

Business formation statistics — tracking EIN applications as a leading indicator of
entrepreneurial activity — provide an early signal of economic momentum that establishment
counts and employment data can only confirm after the fact. For rural communities, this
leading-indicator quality is particularly valuable: formation trends often anticipate
employment changes by one to three years, giving researchers and community leaders
earlier visibility into whether economic conditions are improving or deteriorating.

Rural business application rates surged during and after the pandemic across many county
types, reflecting a combination of genuine entrepreneurial opportunity and structural
adaptation. Communities with strong asset bases — lower cost structures, available
commercial space, community networks, improving broadband — were positioned to convert
application activity into durable establishment growth. Those without those conditions
saw formation surge without corresponding follow-through.

**TBD:** More specific rural vs. nonrural conversion rate findings — CORI research
documents application trends but systematic rural/nonrural comparison of formation-to-
establishment conversion not yet consolidated.

---

## census-building-permits

🔶 Partial evidence

Building permits capture the forward-looking signal of housing supply — new construction
before it becomes occupied stock. For rural communities navigating economic transition,
the permit data is a useful indicator of whether housing markets are responding to
demand changes and whether local regulatory conditions are permissive enough to allow
growth.

CORI's community research has documented housing supply shortfall as a binding constraint
in rural communities that are otherwise well-positioned for growth. Where permit activity
lags population and employment trends, housing functions as a ceiling on the community's
capacity to retain and attract residents — regardless of the quality of its other assets.

**TBD:** Systematic rural vs. nonrural permit trends — specific comparative findings
not yet consolidated from CORI research.

---

# PROJECTS

---

## rural-economic-outlook

✅ Strong evidence

The Rural Economic Outlook project examines how rural communities have fared in the
long-run recovery since the Great Recession, using a multi-indicator framework that
spans employment, wages, business formation, population, broadband, and sectoral
composition. The analysis tracks conditions over a 17-year horizon — long enough to
separate cyclical recovery from structural change — and uses 2007 as an indexed
baseline to support comparison across communities and against national trends.

The central finding is that rural economic performance is not monolithic. Communities
that entered the post-recession period with strong tradable sector assets — particularly
in sectors with growing national demand — have generally shown stronger employment and
wage trajectories. Communities concentrated in legacy industries facing secular decline
have shown more persistent gaps. The data does not tell a story of universal rural
struggle or universal rural resilience; it tells a story of divergence, and reveals
the structural conditions associated with different trajectories.

Several cross-cutting patterns emerge. Population dynamics are more complex than simple
out-migration narratives suggest: communities gaining older in-migrants while losing
working-age residents face different strategic conditions than those with net population
decline across all age cohorts. Broadband coverage has expanded substantially but
adoption lags availability in many rural communities, limiting the economic benefits that
infrastructure investment was designed to produce. And entrepreneurial activity —
measured through business applications and formation rates — has shown meaningful
momentum in communities with strong foundational assets, even where employment growth
has been slower to materialize.

---

## rwjf-seeds-of-change-public-funding

✅ Strong evidence

The Seeds of Change Public Funding project examines how public revenues and expenditures
flow through local government systems — counties, townships, municipalities, special
districts, and schools — across rural and nonrural jurisdictions over a 45-year horizon.
The analysis draws on Census of Governments data inflation-adjusted to current dollars,
making it possible to examine whether rural communities have had the fiscal capacity to
invest in the infrastructure and services that economic development requires.

The project documents a long-run divergence in fiscal capacity between rural and
nonrural jurisdictions. Rural local governments have historically had narrower own-source
revenue bases — more dependent on state and federal transfers and less able to generate
revenue from local economic activity — which limits their capacity to invest in the
conditions that attract and retain residents and businesses. This is not a failure of
policy alone; it reflects the structural economics of lower population density, smaller
commercial tax bases, and the cost of delivering services across greater geographic area.

The analysis makes visible a dimension of rural economic conditions that labor market
and business data alone cannot capture: the capacity of local institutions to invest in
their communities over time. Where fiscal capacity is constrained, communities may be
unable to maintain or improve the public assets — roads, schools, parks, utilities —
that support quality of life and economic competitiveness, even when private economic
conditions are improving.

---

## capital-one-business-demographics

🔶 Partial evidence

The Capital One Business Demographics project constructs a Rural Entrepreneurship Index
that captures entrepreneurial vitality as a multidimensional phenomenon — combining
business formation, innovation output, self-employment, and private investment into a
single county-level measure. The index is designed specifically for rural analysis,
using robust methodological approaches that prevent high-activity coastal metros from
distorting the baseline and making rural variation invisible.

The index documents substantial heterogeneity in rural entrepreneurial capacity. Some
rural communities — those with strong university ecosystems, amenity advantages, or
early-mover positions in emerging sectors — show entrepreneurial metrics that rival or
exceed national benchmarks. The majority show more modest activity, reflecting the
structural conditions that shape access to capital, networks, and markets in lower-
density communities. The index makes this variation legible and comparable, supporting
targeted investment and strategy rather than treating rural entrepreneurship as uniformly
deficient or uniformly strong.

The project also highlights that rural entrepreneurship serves dual purposes that are
not always visible in aggregate metrics: job creation for the community, and wealth
creation for the founder. Communities that support entrepreneurship are building both
dimensions simultaneously, and the distinction matters for how programs and policies
are designed and evaluated.

**TBD:** Specific index findings and rural vs. nonrural comparisons — revisit after
deeper review of project outputs.

---

*Last updated: 2026-08-27*
*Review against: CORI Economic Development Tool metric descriptions, proj_emporia,
data-rural-economic-outlook, proj_capitalone, proj_community_profiles, proj_ecmc,
proj_rwjf_seed_of_change, proj_rwjf_soc_2_public_funding, data-calix-impact-tool*
