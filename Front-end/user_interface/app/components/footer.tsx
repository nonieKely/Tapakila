import { Box, Container, Stack, Text } from "@chakra-ui/react";
import Link from "next/link";
import Provider from "@/app/components/provider";

export default function Footer() {
    return (
        <Provider>
      <Box bg="gray.900" color="white" py={4} position={"sticky"} top={"90dvh"}>
        <Container maxW="container.lg">
          <Stack
            direction={{ base: 'column', md: 'row' }}
            justify="space-between"
            align="center"
          >
            <Text>
              &copy; {new Date().getFullYear()} TAPAKILA. Tous droits réservés.
            </Text>
            <Stack direction="row" gap={4}>
              <Link href="/about">
                À propos
              </Link>
              <Link href="/contact">
                Contact
              </Link>
              <Link href="/privacy">
                Confidentialité
              </Link>
            </Stack>
          </Stack>
        </Container>
      </Box>
      </Provider>
    );
  }