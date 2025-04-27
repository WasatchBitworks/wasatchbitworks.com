/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./views/**/*.erb",   // for Sinatra views (if you're using ERB files)
    "./public/**/*.html", // if you have raw HTML files
    "./src/**/*.js",      // if you start adding JavaScript files
    "./*.html",           // top-level HTML files
  ],
  theme: {
    extend: {
      colors: {
        bizworks: "#1a202c", // Example: custom color for Wasatch Bitworks brand
      },
    },
  },
  plugins: [],
}