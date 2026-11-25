import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {

  final PostModel post;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.only(
        bottom: 18,
      ),

      elevation: 4,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      clipBehavior:
          Clip.antiAlias,

      child: InkWell(

        onTap: onTap,

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // IMAGEN
            post.imagen.isEmpty
                ? _sinImagen(180)
                : Image.network(
                    post.imagen,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _sinImagen(180),
                  ),

            Padding(

              padding:
                  const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // CATEGORÍA
                  Text(
                    post.categoria,

                    style: const TextStyle(
                      color:
                          Color(0xFF2196F3),

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // TÍTULO
                  Text(
                    post.titulo,

                    style: const TextStyle(
                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          Color(0xFF08245C),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // DESCRIPCIÓN
                  Text(
                    post.descripcion,

                    maxLines: 2,

                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 14,
                      color:
                          Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // AUTOR Y FECHA
                  Row(

                    children: [

                      const Icon(
                        Icons.person_outline,
                        size: 18,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(
                        post.autor,
                      ),

                      const Spacer(),

                      Text(
                        post.fecha,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sinImagen(double alto) {
    return Container(
      height: alto,
      width: double.infinity,
      color: const Color(0xFFE7EAF2),
      child: const Icon(Icons.image_not_supported_outlined, size: 40),
    );
  }
}
