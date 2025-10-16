/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'rootstock': {
          'bg': '#0D0D0D',
          'primary': '#F7931A',
          'text': '#FFFFFF',
          'card': '#1A1A1A',
          'border': '#333333',
        }
      },
      fontFamily: {
        'sans': ['Inter', 'system-ui', 'sans-serif'],
      },
      animation: {
        'glow': 'glow 2s ease-in-out infinite alternate',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        glow: {
          '0%': { boxShadow: '0 0 5px #F7931A, 0 0 10px #F7931A, 0 0 15px #F7931A' },
          '100%': { boxShadow: '0 0 10px #F7931A, 0 0 20px #F7931A, 0 0 30px #F7931A' },
        }
      }
    },
  },
  plugins: [],
}