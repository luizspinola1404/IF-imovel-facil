import { db } from "../server/db";
import { users } from "../shared/models/auth";

async function main() {
  const allUsers = await db.select().from(users);
  console.log("Users in Database:");
  console.log(JSON.stringify(allUsers.map(u => ({ id: u.id, username: u.username, email: u.email, role: u.role })), null, 2));
  process.exit(0);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
