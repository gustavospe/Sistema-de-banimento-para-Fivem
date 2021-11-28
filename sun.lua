local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

    --=======================================--
    --====== POWERED BY SPENGLER #0001 ======--
    --=======================================--

-- DataBase para VRP e VRPEX
vRP.prepare('vekez/RegistraTempban','INSERT INTO vekez_tempban (id, user_id, banido, tempban) VALUES (id, @idpessoa, @banido, @tempban)')
vRP.prepare('vekez/RetiraBan','DELETE FROM vekez_tempban WHERE user_id = @idpessoa')
vRP.prepare('vekez/RecebeTemp','SELECT * FROM vekez_tempban WHERE user_id = user_id')
vRP.prepare('vekez/VerificaTemp','SELECT * FROM vekez_tempban WHERE user_id = @user_id')

-- DataBase Para ESX (Creative)
vRP.prepare('vekez/SetBanned','UPDATE vrp_infos SET banned = 1 WHERE id = @user_id')
vRP.prepare('vekez/SetUnbanned','UPDATE vrp_indos SET banned = 0 WHERE id = @user_id')

RegisterCommand(vekez.ComandoTempBan, function(source,args)
    local user_id = vRP.getUserId(source)
    for k, v in pairs(vekez.PermissaoUsarComando) do
        if vRP.hasPermission(user_id, v) then 
            if args[1] ~= nil and args[2] ~= nil then 
                if vekez.UsarHoraDia == 'dia' then
                    local idbanido = vRP.getUserSource(parseInt(args[1]))
                    local tempodefinido = parseInt(args[2])
                    local tempobanido = parseInt(86400*tempodefinido-(os.time()-os.time()))
                    local banidopor = getTempoBanido(tempobanido)
                    DropPlayer(idbanido,"Você recebeu um Temp-Ban de "..banidopor.."! [ Mais informações em: "..vekez.LinkDiscord.." ]")
                    vRP.execute('vekez/RegistraTempban',{idpessoa = parseInt(args[1]), banido = os.time(), tempban = tempobanido})
                    if not vekez.BaseCreative then
                        vRP.setBanned(parseInt(args[1]),true)
                    else
                        vRP.execute('vekez/SetBanned',{user_id = parseInt(args[1])})
                    end
                elseif vekez.UsarHoraDia == 'hora' then
                    local idbanido = vRP.getUserSource(parseInt(args[1]))
                    local tempodefinido = parseInt(args[2])
                    local tempobanido = parseInt(86400*tempodefinido-(os.time()-os.time()))
                    local banidopor = getTempoBanido(tempobanido)
                    DropPlayer(idbanido,"Você recebeu um Temp-Ban de "..banidopor.."! [ Mais informações em: "..vekez.LinkDiscord.." ]")
                    vRP.execute('vekez/RegistraTempban',{idpessoa = parseInt(args[1]), banido = os.time(), tempban = tempobanido})
                    if not vekez.BaseCreative then
                        vRP.setBanned(parseInt(args[1]),true)
                    else
                        vRP.execute('vekez/SetBanned',{user_id = parseInt(args[1])})
                    end
                end
            else
                TriggerClientEvent('Notify',source,'negado','Você está usando o comando errado: /'..vekez.ComandoTempBan..' IDPessoa TempoBanido')
            end
        end
    end
end)

RegisterCommand(vekez.ComandoRetirarTempBan, function(source,args)
    local user_id = vRP.getUserId(source)
    for k, v in pairs(vekez.PermissaoUsarComando) do
        if vRP.hasPermission(user_id, v) then 
            if args[1] ~= nil then 
                vRP.execute('vekez/RetiraBan',{idpessoa = parseInt(args[1])})
                if not vekez.BaseCreative then
                    vRP.setBanned(parseInt(args[1]),false)
                else
                    vRP.execute('vekez/SetUnbanned',{user_id = parseInt(args[1])})
                end
            else
                TriggerClientEvent('Notify',source,'negado','Você está usando o comando errado: /'..vekez.ComandoRetirarTempBan..' IDPessoa')
            end
        end
    end
end)

CreateThread(function()
    while true do 
        Wait(1000)
        local table = vRP.query('vekez/RecebeTemp',{user_id = user_id})
        for k,v in pairs(table) do 
            local tempo = v.banido+v.tempban
            if os.time() >= tempo then 
                local idpessoa = v.user_id
                vRP.execute('vekez/RetiraBan',{idpessoa = v.user_id})
                if not vekez.BaseCreative then
                    vRP.setBanned(idpessoa,false)
                else
                    vRP.execute('vekez/SetUnbanned',{user_id = idpessoa})
                end
            end
        end
    end
end)

function getTempoBanido(seconds)
    local days = math.floor(seconds/86400)
    seconds = seconds - days * 86400
    local hours = math.floor(seconds/3600)
    seconds = seconds - hours * 3600
    local minutes = math.floor(seconds/60)
    seconds = seconds - minutes * 60

    if days > 0 then
        return string.format("%d Dias e %d Horas",days,hours)
    elseif hours > 0 then
        return string.format("%d Horas",hours)
    elseif minutes > 0 then
        return string.format("%d Minutos e %d Segundos",minutes,seconds)
    else
        return string.format("%d Segundos",seconds)
    end
end


AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    local source = source
    local user_id = vRP.getUserId(source)
    deferrals.update('Fazendo algumas verificações de segurança...')
    Citizen.Wait(1)
    deferrals.update(TempoBanido(user_id))
    SetTimeout(5000,function()
        deferrals.done()
    end)
end)

function TempoBanido(user_id)
    local source = source
    local user_id = vRP.getUserId(source)
    local esse = vRP.query('vekez/VerificaTemp',{user_id = 1})
    for k,v in pairs(esse) do 
        local diabanido = v.banido
        local tempban = v.tempban
        local somatemp = parseInt(1*tempban-(os.time()-diabanido))
        local sobroutemp = getTempoBanido(somatemp)
        local msg = 'Você ainda está banido por '..sobroutemp..'!'
        return msg 
    end
end
