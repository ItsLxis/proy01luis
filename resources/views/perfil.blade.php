<!DOCTYPE html>
<html lang="en">

<head>
    <title>Mi Perfil</title>
    <link rel="icon" type="image/x-icon" href="{{ asset('favicon.ico') }}">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    {{--   <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"> </script> --}}
    <link rel="stylesheet" href="{{ asset('/libs/bootstrap/bootstrap.min.css') }}">
    <script src="{{ asset('/libs/bootstrap/bootstrap.bundle.min.js') }}"></script>

</head>

<body>
    <div class="container mt-3">
        <h2>esta es mi informacion</h2>
        <div class="card" style="width: 400px">
            <img src="{{ asset('/images/omen.jpg') }}" alt="Avatar" style="width:100%">
            <div class="card-body">
                <h4 class="card-title">Luis Humberto Gomez Gomez</h4>
                <p class="card-text">Hola soy temach y me gusta leer<br>
                    protejo a las mujeres y me gusta el matcha.</p>
                <a href="#" class="btn btn-primary">See Profile</a>
            </div>
        </div>
    </div>
</body>

</html>
