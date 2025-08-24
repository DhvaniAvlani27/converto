/** @type {import('next').NextConfig} */
const nextConfig = { //What is this 
  output: 'standalone',
  experimental: {
    outputFileTracingRoot: undefined,
  },
};

export default nextConfig;    