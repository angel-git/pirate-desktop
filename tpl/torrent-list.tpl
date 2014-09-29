<table>
    <thead>
        <tr>
            <th align="left">Name</th>
            <th>Seeds</th>
            <th>Leeds</th>
        </tr>
    </thead>
    <tbody>
        {{#.}}
            <tr>
                <td>
                    <span class="torrent-text">
                        <div class="torrent-title"><a href="{{link}}">{{name}}</a></div>
                        <div class="torrent-info">{{desc}}</div>
                    </span>
                </td>
                <td  align="center" class="torrent-seed">{{seeds}}</td>
                <td  align="center" class="torrent-leed">{{leeds}}</td>
            </tr>
        {{/.}}
    </tbody>
</table>

