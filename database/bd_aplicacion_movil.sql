-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 25-11-2026 a las 01:01:50
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bd_aplicacion_movil`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `blog`
--

CREATE TABLE `blog` (
  `id_blog` int(11) NOT NULL,
  `titulo` varchar(150) NOT NULL,
  `desc` text DEFAULT NULL,
  `img` varchar(500) DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `usr_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `blog`
--

INSERT INTO `blog` (`id_blog`, `titulo`, `desc`, `img`, `tags`, `fecha`, `usr_id`) VALUES
(1, 'Construyendo aplicaciones con Flutter', 'Una introducción al desarrollo móvil con Dart.', 'https://picsum.photos/800/400?random=1', 'Flutter,Dart', '2026-11-20 20:30:26', 1),
(2, 'Introducción a la inteligencia artificial', 'Conceptos fundamentales de inteligencia artificial.', 'https://picsum.photos/800/400?random=2', 'IA,tecnología', '2026-11-20 20:30:26', 1),
(3, 'Mi primera publicación', 'Estoy aprendiendo a crear publicaciones con FastAPI, SQLAlchemy y MySQL.', 'https://ejemplo.com/mi-imagen.jpg', 'python, fastapi, programacion', '2026-11-20 20:30:26', 11),
(4, 'Mi primera publicación', 'Mi primer blog con json', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJCqUqbHQodR6H5VELcWgbUbzRwtReIxGZQ6InSbiyVMCIkhNa-YkhxV0h&s=10', 'python, fastapi, programacion', '2026-11-20 20:30:26', 11),
(5, 'Mosquitos Asesinos', 'Existe una variedad de mosquitos y algunos solo provocan comezón, pero otros podrian provocar tu muerte', NULL, NULL, '2026-11-20 20:30:26', 11);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comentarios`
--

CREATE TABLE `comentarios` (
  `id_com` int(11) NOT NULL,
  `comentario` text NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `estatus` int(11) NOT NULL DEFAULT 1,
  `usr_id` int(11) NOT NULL,
  `blog_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `comentarios`
--

INSERT INTO `comentarios` (`id_com`, `comentario`, `fecha`, `estatus`, `usr_id`, `blog_id`) VALUES
(1, 'Muy útil la explicación de Flutter.', '2026-10-19 19:48:59', 1, 1, 1),
(2, 'Me gustaría ver más ejemplos.', '2026-10-19 19:48:59', 1, 2, 1),
(3, 'Buen artículo de introducción.', '2026-10-19 19:48:59', 1, 1, 2),
(4, 'comentario 1', '2026-10-20 19:36:06', 1, 3, 1),
(5, 'comentario 2', '2026-10-20 19:36:20', 1, 3, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usr` int(11) NOT NULL,
  `nom_usr` varchar(100) NOT NULL,
  `mail` varchar(150) NOT NULL,
  `pass` varchar(255) NOT NULL,
  `dir_usr` varchar(200) DEFAULT NULL,
  `tip_usu` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usr`, `nom_usr`, `mail`, `pass`, `dir_usr`, `tip_usu`) VALUES
(1, 'Adriana Contreras', 'adriana@ejemplo.com', 'HASH_DE_PRUEBA', 'Querétaro', 1),
(2, 'Carlos Pérez', 'carlos@ejemplo.com', 'HASH_DE_PRUEBA', 'Querétaro', 2),
(3, 'David Angeles', 'angelesdavid@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$n5L830N19JmdUOs36+8R8w$x+NBn3p384R6KeY9MRDliBvjpfe0u8MvF3F38Jsvi7E', 'Queretaro, Mexico', 1),
(4, 'Prueba 2', 'prueba_backend@ejemplo.com', '$argon2id$v=19$m=65536,t=3,p=4$QzJmdShWLazUF7NT6tZLaw$CTxzG63HtQO0XWx0rNSgJAyVJ/8Y2C/uKfwG90JLHeE', 'Queretaro', 1),
(6, 'Prueba 2', 'correoprueba@ejemplo.com', '$argon2id$v=19$m=65536,t=3,p=4$xM3EiCiTr6A7V869udJmgQ$hZXpzNR36IFy/cp8QH96ET1IhXvh9a04sJ0ApFha+3s', 'Queretaro', 1),
(7, 'Usuario de prueba', 'prueba.login2026@ejemplo.com', '$argon2id$v=19$m=65536,t=3,p=4$HKi9I4tVqyuoVBlvlfU6vg$OkW9hHjhLc5VnEf3dOc0CLyrvyXi8HBgfVb/+VTV71M', 'Queretaro', 1),
(8, 'Usuario tipo 2', 'prueba.tipo2@ejemplo.com', '$argon2id$v=19$m=65536,t=3,p=4$gBCy/5wfE4JL3NIjuk7NuA$WfgD9QA22dsgw5z6KOVjHc5j5BlvhJfj5LxgiD//SZM', 'Queretaro', 2),
(9, 'Gerry Lopez', 'gerry.lopez@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$m2Y8eb4Q6/sCr5dOuRexXg$9y/9AOE0AAjL80MCHOMhnEfoi8/TrJZsC1FErk5f2kU', NULL, 2),
(10, 'Noe Angeles', 'noe.angeles@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$XiyMOriZ1u92vR0MwLukOw$44n81CAMVdyRXZsjkdGYAwBQZjA6sNA3PkRlrnni1gM', NULL, 2),
(11, 'Noe David Angeles Casanova', 'admin.david@ejemplo.com', '$argon2id$v=19$m=65536,t=3,p=4$iN1xe6PSwqtokVyaT+KYCw$kbTRbuka4MO9Zug4Km2f/FATygvcOgrN4pruYTz/NDo', 'Mexicas 121 Cerrito Calaveras', 1),
(12, 'angelo', 'angelo@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$kG9ct7UtAdFjf6MNSS+OKg$pbzmZypxtiO5XVUVNZQ9RKsjaqbqYdxJh+KRDMHuoTs', NULL, 2);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `blog`
--
ALTER TABLE `blog`
  ADD PRIMARY KEY (`id_blog`),
  ADD KEY `idx_blog_usr` (`usr_id`);

--
-- Indices de la tabla `comentarios`
--
ALTER TABLE `comentarios`
  ADD PRIMARY KEY (`id_com`),
  ADD KEY `fk_com_usuario` (`usr_id`),
  ADD KEY `fk_com_blog` (`blog_id`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usr`),
  ADD UNIQUE KEY `mail` (`mail`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `blog`
--
ALTER TABLE `blog`
  MODIFY `id_blog` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `comentarios`
--
ALTER TABLE `comentarios`
  MODIFY `id_com` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `blog`
--
ALTER TABLE `blog`
  ADD CONSTRAINT `fk_blog_usuario` FOREIGN KEY (`usr_id`) REFERENCES `usuario` (`id_usr`) ON DELETE SET NULL;

--
-- Filtros para la tabla `comentarios`
--
ALTER TABLE `comentarios`
  ADD CONSTRAINT `fk_com_blog` FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id_blog`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_com_usuario` FOREIGN KEY (`usr_id`) REFERENCES `usuario` (`id_usr`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
