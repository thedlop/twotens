import React, { useState, useEffect } from 'react';
import { encode } from './tens';

function MessageForm(message, setMessage) {
  function handleChange(e) {
    setMessage(e.target.value);
  }

  return(
    <label>
      <textarea value={message} onChange={handleChange} />
    </label>
  );
}

function Piece(message, color, irSize, imageData) {

  function Image() {
    if(imageData != null) {
      let dataUri = "data:image/png;base64, " + imageData;
      return(
        <div>
        <img src={dataUri}/>
        <div>
          {imageData}
        </div>
        </div>
      )
    } else {
      return(
        <div>
          Creating your 1010s... 
        </div>
      );
    }
  }

  return (
    <div>
      {Image()}
    </div>
  )
}

function EncodeButton(setBeginEncoding) {
  function handleSubmit(event) {
    console.log("Beginning encoding.....");
    setBeginEncoding(true);
    event.preventDefault();
  }

  return(
    <form onSubmit={handleSubmit}>
      <input type="submit" value="Create 1010s" />
    </form>
  )
}

function Root() {
    const [message, setMessage] = useState("hello dark world");
    const [irSize, setIrSize] = useState(5);
    const [color, setColor] = useState("gray");
    const [beginEncoding, setBeginEncoding] = useState(false);
    const [imageData, setImageData] = useState(null);

    useEffect(() => {
      if(beginEncoding) {
        async function asyncEffect() {
          setImageData(await encode(message, color, irSize));
          console.log("We ran piece effect");
          console.log(imageData);
        }
        asyncEffect()
        .catch(console.error);
      } else {
        console.log("No encoding just yet");
      }
      () => { 
        console.log("Ending effect");
      };
    }, [beginEncoding]);

    function rootBody(imageData) {
      if(beginEncoding) {
        return(
          <div>
            {Piece(message, color, irSize, imageData)}
          </div>
        )
      } else {
        return(
          <div>
            {MessageForm(message,setMessage)}
            {EncodeButton(setBeginEncoding)}
          </div>
        )
      }
    }

    return(
      <div>
        {rootBody(imageData)}
      </div>
    )
}

export default Root;
