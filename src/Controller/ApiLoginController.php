<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Request;
use Doctrine\Persistence\ManagerRegistry;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use App\Entity\User;
use Exception;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\HttpFoundation\Response;

class ApiLoginController extends AbstractController
{

    private $userPasswordHasher;

    public function __construct(UserPasswordHasherInterface $userPasswordHasher)
    {
        $this->userPasswordHasher = $userPasswordHasher;
    }
 
    #[Route('/api/login', name: 'api_login', methods: ['POST'])]
    public function index(Request $request, ManagerRegistry $doctrine): void
    {
/*
        $entityManager = $doctrine->getManager();
        $payload = json_decode(urldecode($request->getContent()), true);
        error_log('===========================> Erreur loggé ');

        $user = $entityManager->getRepository(User::class)->findOneBy(['email'=>$payload['username']]);

        if (!$user) {
            return $this->json(['message' => 'Email inconnu'], 404);
            }
        if (!$this->userPasswordHasher->isPasswordValid($user, $payload['password'])) {
            throw new AccessDeniedHttpException();
        }

//        return $this->json(['message' => 'User authentifié'], 200);
*/
    }

    #[Route('/api/subscribe', name: 'api_subscribe', methods: ['POST'])]
    public function subscribe(Request $request, ManagerRegistry $doctrine): Response
    {

        $payload = json_decode(urldecode($request->getContent()), true);

        $user = new User();
        $user->setEmail($payload['username']);
        $user->setPassword($this->userPasswordHasher->hashPassword($user, $payload['password']));
        $user->setFirstname((''));
        $user->setLastname((''));
        
        try {
        $entityManager = $doctrine->getManager();
        $entityManager->persist($user);
        $entityManager->flush();
        } catch (Exception $e) {
            error_log(($e));
            if ($e->getCode() === 1062) {
                return $this->json(['message' => 'Email deja utilise.'.$e->getCode()], 500);
            }
            return $this->json(['message' => 'Erreur d\'acces a la base. Code : '.$e->getCode()], 503);
        }
 
        return $this->redirectToRoute('api_login', $request->query->all(), 307);
//        return $this->json(['message' => 'User enregistre'], 200);

    }

    #[Route('/api/test', name: 'api_test')]
    public function testlogin(): void
    {
        $pdf = '23_SASS.pdf';
        error_log(PHP_EOL.$pdf.file_exists('./'.$pdf), 3, './error_php.log');
        $headers = [
            'Content-Description' => 'File Transfer',
            'Content-Transfer-Encoding' => 'binary',
            'Content-type' => 'application/octet-stream',
            'Expires' => '0',
            'Content-Length' => ''.filesize($pdf),
            'Access-Control-Allow-Origin' => 'http://localhost:4200',
            'Access-Control-Allow-Headers' => 'content-type',
            'Content-Disposition' => 'attachment; filename='.$pdf
        ];
    
        try {
            $fp = fopen($pdf, "r");
            while (!feof($fp)) {
                error_log(PHP_EOL.'tutu', 3, './error_php.log');
                echo fread($fp, 65536);
                flush(); 
            } 
            fclose($fp); 
        } catch (Exception $e) {
            error_log($e->getMessage().PHP_EOL, 3, './error_php.log');
        }

    }

}
