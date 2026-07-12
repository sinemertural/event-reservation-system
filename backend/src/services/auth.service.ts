import prisma from '../config/prisma';
import bcrypt from 'bcrypt';

export const registerUser = async (name: string, email: string, password: string) => {
    //email kayıtlı mı ?
  const existingUser = await prisma.user.findUnique({ // select * from user where email = email"
    where: { email },
  });

  if (existingUser) {
    throw new Error('Bu e-posta adresi zaten kullanımda.');
  }

  const saltRounds = 10; // hash işlemi 10 defa yapılacak
  const hashedPassword = await bcrypt.hash(password, saltRounds);

  // kullanıcıyı veritabanına kaydet (INSERT işlemi)
  const newUser = await prisma.user.create({ 
    data: {
      name,
      email,
      password_hash: hashedPassword,
    },
  });

  // istemciye password_hash göndermemek için password_hash alanını çıkartıyoruz
  const { password_hash, ...userWithoutPassword } = newUser;
  return userWithoutPassword;
};