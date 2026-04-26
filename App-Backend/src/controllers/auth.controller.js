const supabase = require('../config/supabaseClient');

exports.register = async (req, res) => {
  try {
    const { email, password, name } = req.body;

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: name,
        }
      }
    });

    if (error) return res.status(400).json({ error: error.message });

    res.status(201).json({ message: 'User registered successfully', data });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) return res.status(400).json({ error: error.message });

    res.status(200).json({ message: 'Login successful', data });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
};
