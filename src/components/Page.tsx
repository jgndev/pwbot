import React, { useState, useRef } from "react";
import axios from "axios";

const PasswordGenerator = () => {
  const [password, setPassword] = useState(null);
  const [options, setOptions] = useState({
    includeUppercase: true,
    includeLowercase: true,
    includeNumbers: true,
    includeSpecialCharacters: true,
    length: 12,
  });

  const textRef = useRef<HTMLSpanElement>(null);

  const [showMessage, setShowMessage] = useState(false);

  const apiUrl = process.env.REACT_APP_API_URL;

  const handleCheckboxChange = (e: any) => {
    setOptions({ ...options, [e.target.name]: e.target.checked });
  };

  const handleLengthChange = (e: any) => {
    setOptions({ ...options, length: e.target.value });
  };

  const handleCopyPassword = () => {
    const text = textRef.current?.innerText;
    if (text) {
      navigator.clipboard.writeText(text);
      setShowMessage(true);
      setTimeout(() => setShowMessage(false), 1000);
    }
  };

  const handleSubmit = async (e: any) => {
    e.preventDefault();

    try {
      const response = await axios.post(
        `${apiUrl}`,
        options
      );

      setPassword(response.data.password);
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <div className="container">
      {showMessage && <span className="copied">Copied!</span>}
      {password && (
        <div className="password">
          <span ref={textRef}>{password}</span>
          <button onClick={handleCopyPassword}>
            <svg
              width="60"
              height="60"
              viewBox="0 0 76 76"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M28.5 38H40.375M28.5 47.5H40.375M28.5 57H40.375M49.875 59.375H57C58.8897 59.375 60.7019 58.6243 62.0381 57.2881C63.3743 55.9519 64.125 54.1397 64.125 52.25V19.342C64.125 15.7478 61.4492 12.6983 57.8677 12.4007C56.6833 12.3024 55.4978 12.218 54.3115 12.1473M54.3115 12.1473C54.5216 12.8284 54.6252 13.5372 54.625 14.25C54.625 14.8799 54.3748 15.484 53.9294 15.9294C53.484 16.3748 52.8799 16.625 52.25 16.625H38C36.689 16.625 35.625 15.561 35.625 14.25C35.625 13.5185 35.7358 12.8123 35.9417 12.1473M54.3115 12.1473C53.4153 9.24033 50.7047 7.125 47.5 7.125H42.75C41.2276 7.12536 39.7453 7.61312 38.5202 8.51687C37.295 9.42062 36.3914 10.6929 35.9417 12.1473M35.9417 12.1473C34.751 12.2202 33.5667 12.3057 32.3823 12.4007C28.8008 12.6983 26.125 15.7478 26.125 19.342V26.125M26.125 26.125H15.4375C13.471 26.125 11.875 27.721 11.875 29.6875V65.3125C11.875 67.279 13.471 68.875 15.4375 68.875H46.3125C48.279 68.875 49.875 67.279 49.875 65.3125V29.6875C49.875 27.721 48.279 26.125 46.3125 26.125H26.125ZM21.375 38H21.4003V38.0253H21.375V38ZM21.375 47.5H21.4003V47.5253H21.375V47.5ZM21.375 57H21.4003V57.0253H21.375V57Z"
                stroke="black"
                strokeWidth="5"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </button>
        </div>
      )}
      <form onSubmit={handleSubmit}>
        <div className="input-field">
          <input
            type="checkbox"
            name="includeUppercase"
            checked={options.includeUppercase}
            onChange={handleCheckboxChange}
          />
          <label className="uppercase" htmlFor="includeUppercase">
            Uppercase Letters
          </label>
        </div>
        <div className="input-field">
          <input
            type="checkbox"
            name="includeLowercase"
            checked={options.includeLowercase}
            onChange={handleCheckboxChange}
          />
          <label className="lowercase" htmlFor="includeLowercase">
            Lowercase Letters
          </label>
        </div>
        <div className="input-field">
          <input
            type="checkbox"
            name="includeNumbers"
            checked={options.includeNumbers}
            onChange={handleCheckboxChange}
          />
          <label className="uppercase" htmlFor="includeNumbers">
            num83r5
          </label>
        </div>
        <div className="input-field">
          <input
            type="checkbox"
            name="includeSpecialCharacters"
            checked={options.includeSpecialCharacters}
            onChange={handleCheckboxChange}
          />
          <label className="uppercase" htmlFor="includeSpecialCharacters">
            $pe[!@l [h@r@[ter$
          </label>
        </div>
        <div className="number-input">
          <label htmlFor="length">Length</label>
          <input
            type="number"
            name="length"
            min="1"
            max="100"
            step="1"
            value={options.length}
            onChange={handleLengthChange}
          />
        </div>
        <div className="submit-button">
          <button type="submit">Generate p@$$w0rd</button>
        </div>
      </form>
    </div>
  );
};

export default PasswordGenerator;
