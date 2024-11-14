import axios from 'axios';
import React from 'react'
import { useDrag, useDrop } from 'react-dnd';
import cross from "../assets/images/icon-cross.svg"
import check from "../assets/images/icon-check.svg"

function TodoItem({ todo, index, moveTodo, setData }) {
    const ref = React.useRef(null);

    const [, drag] = useDrag({
        type: 'TODO',
        item: { index }
    });

    const [, drop] = useDrop({
        accept: 'TODO',
        hover: (draggedItem) => {
            if (draggedItem.index !== index) {
                moveTodo(draggedItem.index, index);
                draggedItem.index = index;
            }
        },
    });

    drag(drop(ref));

    const deleteTodo = async (id) => {
        try {
            const apiUrl = process.env.REACT_APP_API_URL; // Use the API URL from the environment variable
            let response = await axios.delete(`${apiUrl}/todo/${id}`);
            if(response.data.status){
                setData(response.data.data);
            }
        } catch (error) {
            console.log(error);
        }
    }

    const completeTodo = async (id) => {
        try {
            const apiUrl = process.env.REACT_APP_API_URL; // Use the API URL from the environment variable
            let response = await axios.put(`${apiUrl}/todo/${id}`);
            if(response.data.status){
                setData(response.data.data);
            }
        } catch (error) {
            console.error(error);
        }
    }

  return (
    <li ref={ref} key={todo._id} className="list_todo--item">
        <div className="todo__content">
            <div className={`complete ${todo.isCompleted ? 'todo--complete' : ""}`} onClick={() => completeTodo(todo._id)}></div>
            <p className={`text ${todo.isCompleted ? "text--complete" : ''}`} >{todo.todo}</p>
        </div>
        <div className='close_icon' onClick={()=> deleteTodo(todo._id)}>
            <img src={cross} alt="close icon" />
        </div>
    </li>
  )
}

export default TodoItem
