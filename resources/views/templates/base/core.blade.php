@extends('templates/wrapper', [
    'css' => ['body' => 'bg-neutral-900'],
])

@section('container')
    <style id="arix-dashboard-fixes">
      html, body {
        background-color: var(--gray900) !important;
      }
      [class*="App___StyledDiv"] {
        background: transparent !important;
      }
      h1, h2, h3, h4, h5, h6 {
        font-family: 'IBM Plex Sans', 'Rubik', sans-serif !important;
      }
      @media screen and (max-width: 768px) {
        [class*="PageContentBlock___StyledContentContainer"] {
          padding: 16px !important;
        }
      }
    </style>

    <div id="modal-portal"></div>
    <div id="app"></div>
@endsection