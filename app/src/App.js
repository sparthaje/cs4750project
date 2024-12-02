import React, { useState } from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';
import { Button, Modal, Form } from 'react-bootstrap';

function App() {
  return (
    <div className="min-h-screen d-flex align-items-center justify-content-center bg-light">
      <div className="d-flex gap-3">
        <SignInModal />
        <SignUpModal />
      </div>
    </div>
  );
}

function SignInModal() {
  const [email, setEmail] = useState('');
  const [username, setUsername] = useState('');
  const [error, setError] = useState('');
  const [show, setShow] = useState(false);

  const handleSignIn = async (e) => {
    e.preventDefault();
    setError('');

    try {
      const response = await fetch('http://localhost:5000/api/signin', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, username }),
      });

      const data = await response.json();
      console.log(data.uid);

      if (data.uid !== undefined) {
        // Store user information in local storage or context
        localStorage.setItem('userProfile', JSON.stringify(data));
        console.log('Signed in successfully', data);
      } else {
        console.log('Sign in failed', data.message);
        setError(data.message || 'You provided invalid credentials');
      }
    } catch (error) {
      setError('Error signing in. Please try again.');
      console.error('Sign in error', error);
    }
  };

  return (
    <>
      <Button variant="outline-primary" onClick={() => setShow(true)}>
        Sign In
      </Button>

      <Modal show={show} onHide={() => setShow(false)} centered>
        <Modal.Header closeButton>
          <Modal.Title>Sign In</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form onSubmit={handleSignIn}>
            <Form.Group className="mb-3" controlId="username">
              <Form.Label>Username</Form.Label>
              <Form.Control
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
              />
            </Form.Group>
            <Form.Group className="mb-3" controlId="email">
              <Form.Label>Email</Form.Label>
              <Form.Control
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </Form.Group>
            {error && <p className="text-danger">{error}</p>}
            <Button variant="primary" type="submit" className="w-100">
              Sign In
            </Button>
          </Form>
        </Modal.Body>
      </Modal>
    </>
  );
}

function SignUpModal() {
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');
  const [show, setShow] = useState(false);

  const handleSignUp = async (e) => {
    e.preventDefault();
    setError('');

    try {
      const response = await fetch('http://localhost:5000/api/signup', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, email }),
      });

      const data = await response.json();

      if (data.success) {
        console.log('Signed up successfully', data.user);
      } else {
        setError(data.message || 'Sign up failed');
      }
    } catch (error) {
      setError('Error signing up. Please try again.');
      console.error('Sign up error', error);
    }
  };

  return (
    <>
      <Button variant="primary" onClick={() => setShow(true)}>
        Sign Up
      </Button>

      <Modal show={show} onHide={() => setShow(false)} centered>
        <Modal.Header closeButton>
          <Modal.Title>Sign Up</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form onSubmit={handleSignUp}>
            <Form.Group className="mb-3" controlId="new-username">
              <Form.Label>Username</Form.Label>
              <Form.Control
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
              />
            </Form.Group>
            <Form.Group className="mb-3" controlId="new-email">
              <Form.Label>Email</Form.Label>
              <Form.Control
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </Form.Group>
            {error && <p className="text-danger">{error}</p>}
            <Button variant="primary" type="submit" className="w-100">
              Create Account
            </Button>
          </Form>
        </Modal.Body>
      </Modal>
    </>
  );
}

export default App;