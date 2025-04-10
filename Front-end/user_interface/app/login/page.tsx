"use client";
import { useEffect, useState } from "react";
import { Box, Button, Input, Heading, VStack, Icon } from "@chakra-ui/react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { emailSchema } from "@/schema/emailSchema";
import { FaArrowLeft } from "react-icons/fa";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const router = useRouter();
  const [invited, setInvited] = useState(false);

  useEffect(() => {
    if (localStorage.getItem("authToken")) {
      router.replace("/profile");
    }
    else {
      setInvited(true);
    }
  }, [router])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!email || !password) {
      setError("All fields are required");
      return;
    }

    const result = emailSchema.safeParse(email);
    if (!result.success) {
      setError(result.error.format()._errors[0]);
      return;
    }

    await fetch("http://localhost:3001/users/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    })
      .then(response => response.json())
      .then(user => {
        localStorage.setItem("authToken", user.finalUser.authToken);
        localStorage.setItem("username", user.finalUser.username);
        localStorage.setItem("userId", user.finalUser.id);
        router.replace("/");
      })
      .catch(error => {
        setError(error)
      })
  };

  return (
    <>
      <Link href="/" >
        <Button ><Icon><FaArrowLeft /></Icon></Button>
      </Link>
      {
        invited &&
        <Box minH={"xl"} display="flex" alignItems="center" justifyContent="center">
          <VStack gap={4} p={8} boxShadow="lg" borderRadius="md" bg="white" _dark={{ bg: "gray.900" }}>
            <Heading>Sign in</Heading>
            {error && <Box color="red.500">{error}</Box>}
            <form onSubmit={handleSubmit} style={{ width: "100%" }}>
              <Input
                variant={"flushed"}
                m={2}
                placeholder="E-mail"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
              <Input
                variant={"flushed"}
                m={2}
                placeholder="Password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
              <Box textAlign="right">
                <Link href="/signup">
                  <Button colorScheme="blue" variant="ghost" size="sm" m={2}>Sign up</Button>
                </Link>
              </Box>
              <Button mt={4} colorScheme="purple" type="submit" width="full">Login</Button>
            </form>
          </VStack>
        </Box>
      }
    </>
  );
}
