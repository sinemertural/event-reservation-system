import prisma from '../config/prisma';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

export const registerUser = async (name: string, email: string, password: string) => {
    //email kayıtlı mı ?
  const existingUser = await prisma.user.findUnique({ // select * from user where email = email"
    where: { email },
  });

  if (existingUser) {
    throw new Error('Bu e-posta adresi zaten kullanımda.');
  }

  const saltRounds = 10; // hash işlemi 10 defa yapılacak
  const hashedPassword = await bcrypt.hash(password, saltRounds); //bcrypt.hash ile şifreyi hashliyoruz

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

export const loginUser = async (email: string, password: string) => {
  const user = await prisma.user.findUnique({ // select * from user where email = email"
    where: { email },
  });

  if (!user) {
    throw new Error('Geçersiz e-posta veya şifre.'); // kullanıcı yoksa hata fırlat
  }

  const isPasswordValid = await bcrypt.compare(password, user.password_hash); //bcrypt.compare ile girilen şifreyi hashlenmiş şifre ile karşılaştırıyoruz

  if (!isPasswordValid) {
    throw new Error('Geçersiz e-posta veya şifre.'); 
  }

  const token = jwt.sign({ userId: user.id , email: user.email}, //. jwt.sign ile token oluşturuyoruz. payload (token içine koymak istediğim bilgiler) olarak userId ve email gönderiyoruz. şifre gönderilemez. çünkü payload kısmı çözümlenebilir.
    process.env.JWT_SECRET as string,
    {expiresIn: '7d'} // token 7 gün geçerlidir. 7 günün sonunda kullanıcı tekrar giriş yapmak zorunda kalır.
  );

  const { password_hash, ...userWithoutPassword } = user; // istemciye tekrar sadece id name ve email gönderiyoruz.
  return { token, user: userWithoutPassword };
}