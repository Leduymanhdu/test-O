/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#17a2b8',
          dark: '#138496',
          light: '#5BC0DE',
        },
        secondary: '#E0F7FA',
        accent: '#00BCD4',
        success: '#4CAF50',
        warning: '#FFC107',
        error: '#F44336',
        info: '#2196F3',
      },
      fontFamily: {
        sans: ['Roboto', 'Arial', 'sans-serif'],
      },
      borderRadius: {
        'sm': '2px',
        'md': '4px',
        'lg': '8px',
        'xl': '12px',
      },
      boxShadow: {
        'sm': '0 1px 2px rgba(0,0,0,0.05)',
        'md': '0 2px 8px rgba(0,0,0,0.08)',
        'lg': '0 4px 16px rgba(0,0,0,0.12)',
        'xl': '0 8px 24px rgba(0,0,0,0.15)',
      },
    },
  },
  plugins: [],
}
