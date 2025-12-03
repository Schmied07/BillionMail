/**
 * Build utilities for rsbuild configuration
 */

interface ServerConfig {
	address: string
	https: boolean
}

/**
 * Get environment variable value
 */
export function getEnv(key: string, defaultValue: string = ''): string {
	return process.env[key] || defaultValue
}

/**
 * Get server configuration from environment
 */
export function getServer(): ServerConfig {
	const address = getEnv('VITE_API_URL', getEnv('API_URL', 'http://localhost:8080'))
	const https = address.startsWith('https://')
	
	return {
		address,
		https,
	}
}
