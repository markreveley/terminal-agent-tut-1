// Terminal color theme for the tutorial
export const theme = {
  // Primary colors
  primary: '#7C3AED',      // Violet
  secondary: '#06B6D4',    // Cyan
  accent: '#F59E0B',       // Amber

  // Status colors
  success: '#10B981',      // Green
  error: '#EF4444',        // Red
  warning: '#F59E0B',      // Amber
  info: '#3B82F6',         // Blue

  // Text colors
  text: '#E5E7EB',         // Light gray
  textMuted: '#9CA3AF',    // Muted gray
  textDim: '#6B7280',      // Dim gray

  // Background
  bgHighlight: '#1F2937',  // Dark gray
} as const;

// Box drawing characters
export const box = {
  topLeft: '┌',
  topRight: '┐',
  bottomLeft: '└',
  bottomRight: '┘',
  horizontal: '─',
  vertical: '│',
  teeRight: '├',
  teeLeft: '┤',
  teeDown: '┬',
  teeUp: '┴',
  cross: '┼',
} as const;

// Progress bar characters
export const progress = {
  filled: '█',
  partial: '▓',
  light: '░',
  empty: '░',
} as const;

// Status icons
export const icons = {
  check: '✅',
  cross: '❌',
  warning: '⚠️',
  info: 'ℹ️',
  arrow: '→',
  bullet: '•',
  star: '★',
  folder: '📁',
  file: '📄',
  code: '💻',
  robot: '🤖',
  shell: '🐚',
  beam: '🧬',
  lightning: '⚡',
} as const;
