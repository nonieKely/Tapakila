import express, { json } from 'express';
import UserDAO from '../dao/userDAO.js';
import User from '../entity/User.js';
import authentification from '../authentification.js';

const user = express.Router();

user.get('/', authentification, async (req, res) => {
    try {
        const users = await UserDAO.findAllUsers();
        if(!users){
            return res.status(404).send("La liste d'utilisateur n'est pas disponible")
        }
        res.send(users);
    }
    catch (e) {
        res.status(404).send(e);
    }
})

user.get('/:id', authentification,async (req, res) => {
    try {
        const user = await UserDAO.findUserById(req.params.id);
        if(!user){
            return res.status(404).send("Cet utilisateur n'existe pas")
        }
        res.send(user);
    }
    catch (e) {
        res.status(404).send(e);
    }
})

user.post('/login', async (req, res) => {
    const email = await req.body.email;
    const password = await req.body.password;

    try {
        const verifiedUser = await UserDAO.findUser(email, password);    

        if (!verifiedUser) {
            return res.status(404).send("Cet utilisateur n'existe pas");
        }
        
        const user = new User(
            verifiedUser.username,
            verifiedUser.email,
            verifiedUser.password,
        );
        user.setId(verifiedUser.id);
        user.setStatus(verifiedUser.status);
        
        
        const authToken = user.generateAuthToken();
        await UserDAO.save(user);
        const finalUser = user.toString()
        return res.send({ finalUser });
    }
    catch (e) {
        return res.status(400).send(e);
    }
})

user.post('/logout', authentification, async (req, res) => {
    try{
        const user = new User(
            req.user.username,
            req.user.email,
            req.user.password
        );
        user.setId(req.user.id);
        user.setAuthToken(null);

        await UserDAO.save(user);
        res.send(user)
    }
    catch(e){
        res.status(500).send(e);
    }
})

user.post('/', async (req, res) => {
    const sentUser = new User(
        req.body.username,
        req.body.email,
        req.body.password
    );
    sentUser.setStatus('user');
    
    try {
        if (await UserDAO.findUser(req.body.email, req.body.password)) {
            return res.send("L'email : " + req.body.email + " et/ou le nom : " + req.body.username + " est déjà liée à un compte");
        }

        const userObject = await UserDAO.save(sentUser);

        const createdUser = new User(
            userObject.username,
            userObject.email, 
            userObject.password
        );
        createdUser.setId(userObject.id);
        createdUser.setStatus(userObject.status);
        
        const authToken = createdUser.generateAuthToken();
        return res.status(201).send({ createdUser});
    }
    catch (e) {
        return res.status(400).send(e);
    }
})

export default user;