import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './funradar/App';
import './funradar/index.css';

document.addEventListener('DOMContentLoaded', () => {
  const rootElement = document.getElementById('root');
  if (!rootElement) return;

  const root = createRoot(rootElement);
  root.render(<App />);
});