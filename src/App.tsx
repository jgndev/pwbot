import React from "react";
import Header from './components/Header';
import PasswordGenerator from "./components/PasswordGenerator";

const App = () => {
  return (
    <div className="main">
      <Header />
      <PasswordGenerator />
    </div>
  );
};

export default App;
