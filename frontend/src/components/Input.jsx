import React, {useState} from 'react'
import axios from "axios"

function Input({setData}) {
  const[todo, setTodo] = useState('')
  const[error, setError] = useState(false)

  const handleSubmit = async () => {
    if(todo === ""){
      setError(true)
      console.log("emap");
    }else{
      const response = await axios.post("http://localhost:3500/todo", { todo: todo })
      if(response.data.status){
        setTodo("")
        setData(response.data.data)
      }
    }
  }

  return (
    <>
      <div className='form-group'>
          <label htmlFor="todo"></label>
          <input type="text" placeholder='Create a new todo...' id='todo' value={todo} onChange={(e) => setTodo(e.target.value)} autoComplete="off" />
          <button onClick={() => handleSubmit()}>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
              <path d="M16.1 260.2c-22.6 12.9-20.5 47.3 3.6 57.3L160 376V479.3c0 18.1 14.6 32.7 32.7 32.7c9.7 0 18.9-4.3 25.1-11.8l62-74.3 123.9 51.6c18.9 7.9 40.8-4.5 43.9-24.7l64-416c1.9-12.1-3.4-24.3-13.5-31.2s-23.3-7.5-34-1.4l-448 256zm52.1 25.5L409.7 90.6 190.1 336l1.2 1L68.2 285.7zM403.3 425.4L236.7 355.9 450.8 116.6 403.3 425.4z"/>
            </svg>
          </button>
      </div>

      {error && <p className='error'>field must not be empty</p>}
    </>
  )
}

export default Input
