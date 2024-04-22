import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path';

const resolveDir = dir => path.resolve(__dirname, dir);


// https://vitejs.dev/config/
export default defineConfig(({mode}) => {
    return {
        base: `${process.env.CERN_RESTAURANT_CLIENT_PREFIX}/`,
        plugins: [vue()],
        build: {
            outDir: 'dist/',
        },
        resolve: {
            alias: {
                '@': resolveDir('./src'),
                'vue': 'vue/dist/vue.esm-bundler.js',
            },
        },
        server: {
            host: true,
            port: process.env.CERN_RESTAURANT_CLIENT_PORT,
        },
        test: {
            environment: 'jsdom'
        }
    }
})
