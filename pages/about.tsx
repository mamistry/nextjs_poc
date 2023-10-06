import Link from 'next/link'
import Layout from '../components/Layout'

const AboutPage = () => (
  <Layout title="About | Next.js + TypeScript Example">
    <h1>About</h1>
    <p>This is the about pages</p>
    <p>
      <Link href="/">Go homes</Link>
    </p>
  </Layout>
)

export default AboutPage
