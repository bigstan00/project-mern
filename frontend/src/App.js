import React, { useEffect, useState } from 'react'
import Banner from './components/banner'
import "./App.css"
import Body from './components/Body'
import Todo from './components/Todo'

function App() {

  const [isDarkMode, setIsDarkMode] = useState(() => {
    const savedTheme = localStorage.getItem('isDarkMode');
    return savedTheme === 'true';
  });

  useEffect(() => {
    document.body.setAttribute("data-theme", isDarkMode ? 'light' : 'dark')
  }, [isDarkMode])

  const toggleTheme = () => {
    setIsDarkMode((prevMode) => {
      const newMode = !prevMode;
      localStorage.setItem('isDarkMode', newMode);
      return newMode;
    });
  };

  return (
    <div className='home'>
      <Banner />
      <Body />
      <Todo toggleTheme={toggleTheme} isDarkMode={isDarkMode} />
    </div>
    
  )
}

export default App
