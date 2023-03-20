<?php

namespace App\Controller;

use Exception;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class FilesController extends AbstractController
{

    private $files;

    private function scanFiles(string $path): array
    {

//        $files = [];

        foreach (scandir($path) as $file) {

            if (!in_array($file, ['.', '..'], true)) {
                $childrens = [];
                if (is_dir($path .'/'.$file)) {
                    $childrens = $this->scanFiles($path .'/'.$file);
                } 
                $files[] = ['name' => $path.'/'.$file, 'childrens' => $childrens];
            }

        }

        return $files;

    }

    #[Route('/api/files', name: 'app_api_files')]
    public function index(Request $request): JsonResponse
    {

        $path = $request->query->get('path');

        $this->files = $this->scanFiles($path);

        return $this->json(['path' => $path, 'files' => $this->files], 200);

    }

    #[Route('/api/file', name: 'api_file')]
    public function getFile(Request $request): Response
    {

        $file = $request->query->get('file');

        error_log(PHP_EOL.$file.file_exists($file), 3, './error_php.log');
  
        $content_file = file_get_contents($file);
 
//        unlink($file);
         
        return new Response($content_file, 200 /*, array(
                            "Content-Type: application/octet-stream;",
                            "Content-Disposition" => "attachment; filename=" . basename($file),
                            "Content-Length: " . filesize(realpath($file))
        )*/);

    }

}
