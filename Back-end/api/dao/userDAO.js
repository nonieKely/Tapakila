import pool from "../db.js";

export default class UserDAO {
    static async save(user) {
        if (!await this.findUser(user.email, user.getPassword())) {
            const query = `
            INSERT INTO "user" (username, email, password, birthday, phone, country, city, status, auth_token) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
            RETURNING *;
            `;
            const values = [user.username, user.email, user.getPassword(),user.birthday, user.phone, user.country, user.city, user.getStatus(), user.getAuthToken()];
            const result = await pool.query(query, values);
            
            return result.rows[0];
        }

        const query = `UPDATE "user" SET auth_token=$1 WHERE id=$2;`;
        const result = await pool.query(query, [user.getAuthToken(), user.getId()]);
        return result.rows[0];
    }

    static async updateUser(user){
        if(!await this.findUserById(user.getId())){
            return this.save(user);
        }
        const query = `UPDATE "user" SET username=$1, email=$2, password=$3, birthday=$4, phone=$5, country=$6, city=$7 WHERE id=$8;`;
        const values = [user.username, user.email, user.getPassword(), user.birthday, user.phone, user.country, user.city, user.getId()];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    static async findAllUsers(order, page, perPage, sort) {
        let query = `SELECT * FROM "user"`;

        if (order && sort) {
            query += ` ORDER BY ${sort} ${order}`;
        }
      
        if (page && perPage){
            query += ` LIMIT ${perPage} OFFSET (${page} - 1) * ${perPage}`;
        }

        const result = await pool.query(query);
        
        return result.rows;
    }

    static async findUser(email, password) {
        const query = `SELECT * FROM "user" WHERE email=$1 AND password=$2;`;
        const result = await pool.query(query, [email, password]);
        return result.rows[0];
    }

    static async findUserById(id) {
        if (isNaN(id)) {
            throw new Error("L'ID doit être un entier valide !");
        }
        const query = `SELECT * FROM "user" WHERE id=$1;`;
        const result = await pool.query(query, [id]);
        return result.rows[0];
    }

    static async findUserByIdAndToken(id, authToken) {
        const query = `SELECT * FROM "user" WHERE id=$1 AND auth_token='${authToken}';`;
        const result = await pool.query(query, [id]);
        return result.rows[0];
    }

    static async deleteById(id){
        const query = `DELETE FROM "user" WHERE id=$1 RETURNING *;`;
        const result = await pool.query(query, [id]);
        return result.rows[0];
    }
}