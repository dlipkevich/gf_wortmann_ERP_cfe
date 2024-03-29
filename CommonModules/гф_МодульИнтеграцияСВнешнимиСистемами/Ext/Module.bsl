﻿// Возвращает первую найденную ссылку на элемент справочника "гф_НастройкиИнтеграцииСВнешнимиСистемами"
//
// Параметры:
//  Организация - СправочникСсылка.Организации - Организация;
//  ВнешняяСистема - ПеречислениеСсылка.гф_ВнешниеСистемы - Внешняя система.
//
// Возвращаемое значение:
//  Ссылка на элемент справочника, если есть.
//
Функция ПолучитьНастройкиИнтеграции(Организация, ВнешняяСистема) Экспорт
	
	ПустаяНастройка = Справочники.гф_НастройкиИнтеграцииСВнешнимиСистемами.ПустаяСсылка();
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("ВнешняяСистема", ВнешняяСистема); 
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	гф_НастройкиИнтеграцииСВнешнимиСистемами.Ссылка КАК Ссылка
	               |ИЗ
	               |	Справочник.гф_НастройкиИнтеграцииСВнешнимиСистемами КАК гф_НастройкиИнтеграцииСВнешнимиСистемами
	               |ГДЕ
	               |	НЕ гф_НастройкиИнтеграцииСВнешнимиСистемами.ПометкаУдаления
	               |	И гф_НастройкиИнтеграцииСВнешнимиСистемами.Использовать
	               |	И гф_НастройкиИнтеграцииСВнешнимиСистемами.Организация = &Организация
	               |	И гф_НастройкиИнтеграцииСВнешнимиСистемами.ВнешняяСистема = &ВнешняяСистема";
	Выборка = ЗАпрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	Иначе
		Возврат ПустаяНастройка;
	КонецЕсли;
	
КонецФункции  

//Преобразовывает данные в формате JSON в структуру или соответствие
//
// Параметры:
//  ТекстJSON - строка - текст который необходимо преобразовать;
//  ПрочитатьВСоответствие - Булево - признак необходимости перобразования в соответствие.
//
// Возвращаемое значение:
// Структура или соответствие.
//
Функция ВыполнитьЧтениеJSON(Знач ТекстJSON, ПрочитатьВСоответствие = Ложь) Экспорт
	
	Попытка
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(ТекстJSON);
		РезультатЧтения = ПрочитатьJSON(ЧтениеJSON, ПрочитатьВСоответствие);
		Возврат РезультатЧтения;
	Исключение   
		ТекстОшибки = ОписаниеОшибки();
		ОбщегоНазначения.СообщитьПользователю("При чтении ответа произошла ошибка. "+ТекстОшибки);
		Возврат Неопределено;
	КонецПопытки;
	
КонецФункции 

//Преобразовывает данные (структура или соответствие) в JSON
//
// Параметры:
//  Струкутра - Данные, которые необходимо преобразовать;
//
// Возвращаемое значение:
// JSON.
//
Функция ВыполнитьЗаписьJSON(Знач Струкутра) Экспорт
	
	Попытка 
		ЗаписьJSON = Новый ЗаписьJSON;
		ЗаписьJSON.УстановитьСтроку();
		ЗаписатьJSON(ЗаписьJSON,Струкутра);
		Возврат  ЗаписьJSON.Закрыть();
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		ОбщегоНазначения.СообщитьПользователю("Ошибка формированя JSON. " + ТекстОшибки);
		Возврат Неопределено;
	КонецПопытки;
	
КонецФУнкции

Функция Ожидать(ВремяОжидания) Экспорт
	
	Таймаут = ВремяОжидания; 
	
    Если Таймаут <> 0 Тогда
        
        НастройкиПрокси = Новый ИнтернетПрокси(Ложь);
        НастройкиПрокси.НеИспользоватьПроксиДляЛокальныхАдресов = Истина;
        НастройкиПрокси.НеИспользоватьПроксиДляАдресов.Добавить("127.0.0.0");
        
        Попытка
            Loopback = Новый HTTPСоединение(
                "127.0.0.0",,,,НастройкиПрокси,
                Таймаут);
            Loopback.Получить(Новый HTTPЗапрос());
        Исключение
            Таймаут = 0;
        КонецПопытки;
        
    КонецЕсли;
    
КонецФункции

/////Процедуры HMAC/////
#Область UTF8
Функция ТекстUnicodeToUTF8(Стр) Экспорт
	БезопасныеСимволы = "-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~";
	ИтогСтр = "";
	
	Для й = 1 по  СтрДлина(Стр) Цикл
		ТекСимв = Сред(Стр, й, 1);
		
		Если ТекСимв = " " Тогда
			ИтогСтр = ИтогСтр + "+";
			Продолжить;
		КонецЕсли;
		Если Найти(БезопасныеСимволы, ТекСимв) > 0 Тогда
			ИтогСтр = ИтогСтр + ТекСимв;
			Продолжить;
		КонецЕсли;
		
		Код = КодСимвола(ТекСимв);
		Если Код < 128 Тогда
			ИтогСтр = ИтогСтр +"%"+DecToHex(Код);
		Иначе
			///Конвертиция Unicode to UTF-8 в полном соотвествии со спецификацией
			Делитель = 32;
			Нашлепка = 8;
			КодHEX = "";
			Пока Делитель > 4 Цикл
				///Установка следующих за первым байтов
				ТекБайт = Код % 64;
				КодHEX = "%" + DecToHex(128+ТекБайт)+КодHEX;
				Код = Цел(Код/64);
				///Проверка на закрывающий байт
				Если Код < Делитель Тогда
					КодHEX = "%" + DecToHex((Нашлепка-2)*Делитель+Код)+КодHEX;
					Прервать;
				КонецЕсли;
				///Переход к след уровню
				Делитель = Делитель/2;
				Нашлепка = Нашлепка*2;
			КонецЦикла;
			ИтогСтр = ИтогСтр+КодHEX;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ИтогСтр;

КонецФункции

Функция DecToHex(Знач _Число) Экспорт
                База = 16;
                Результат = "";
                Пока _Число <> 0 Цикл
                               Поз =_Число % База;
                               Результат = Сред("0123456789ABCDEF", Поз + 1, 1) + Результат;
                               _Число = Цел(_Число / База);
                КонецЦикла;
                Возврат Результат;
КонецФункции // DecToHex()
#КонецОбласти

Функция СобратьПараметрыДляХеш(ДанныеАвторизации, Действие, ПараметрыЗапросаLamoda) Экспорт

	TimeStamp = ЗаполнитьДатуФорматISO8601(ТекущаяДата());
	
	ПараметрыUnsorted = Новый Структура;
	ПараметрыUnsorted.Вставить("Action",	Действие);
	Если Действие = "GetProducts" Тогда
		МассивSKU = СформироватьСтрокуДляЗапроса(ПараметрыЗапросаLamoda);
		ПараметрыUnsorted.Вставить("Filter",	"all");
		ПараметрыUnsorted.Вставить("SkuSellerList", МассивSKU)
	ИначеЕсли Действие = "GetCategoryAttributes" Тогда
		ПараметрыUnsorted.Вставить("PrimaryCategory", ПараметрыЗапросаLamoda);
	ИначеЕсли Действие = "GetMappedAttributeOptions" Тогда
		ПараметрыUnsorted.Вставить("AttributeOptionIdList", "["+ПараметрыЗапросаLamoda+"]");
	ИначеЕсли Действие = "FeedStatus" Тогда
		ПараметрыUnsorted.Вставить("FeedID", ПараметрыЗапросаLamoda);
	КонецЕсли;
	Если Действие = "ProductCreate" ИЛИ Действие = "Image" Тогда  	
		ПараметрыUnsorted.Вставить("Format", 	"XML");
	Иначе
		ПараметрыUnsorted.Вставить("Format", 	"JSON");
	КонецЕсли;
	ПараметрыUnsorted.Вставить("Timestamp", TimeStamp);
	ПараметрыUnsorted.Вставить("UserID",	ДанныеАвторизации.UserID);
	ПараметрыUnsorted.Вставить("Version",	"1.0");
	
	ТЗПараметры = Новый ТаблицаЗначений;
	ТЗПараметры.Колонки.Добавить("Ключ");
	ТЗПараметры.Колонки.Добавить("Значение");
	Для каждого параметр из ПараметрыUnsorted цикл
		нСтрока = ТЗПараметры.Добавить();
		нСтрока.Ключ = параметр.Ключ;
		нСтрока.Значение = параметр.Значение;
	КонецЦикла;
	
	ТЗПараметры.Сортировать("Ключ");      //Для формирования Хэш нужно сортировать параметы по ключу.
	
	СтрокаПараметры = "";
	Для каждого стр из ТЗПараметры цикл
		СтрокаПараметры = СтрокаПараметры + стр.Ключ + "=" + ТекстUnicodeToUTF8(стр.Значение) + "&";
	КонецЦикла;
	
	СтрокаПараметры = Лев(СтрокаПараметры, СтрДлина(СтрокаПараметры)-1);
	
	Возврат СтрокаПараметры;
	
КонецФункции

Функция СформироватьСтрокуДляЗапроса(Параметры)
	
	Если ТипЗнч(Параметры) = Тип("Массив") Тогда
		Строка = "[";
		Для каждого стрм из Параметры цикл
			Строка = Строка+""""+стрм+""""+",";
		КонецЦикла;
		Строка = Лев(Строка, СтрДлина(Строка)-1);
		Строка = Строка+"]";
		Возврат Строка;
	КонецЕсли;
	
КонецФункции

Функция ЗаполнитьДатуФорматISO8601(Дата) Экспорт

Время = ЗаписатьДатуJSON(Дата, ФорматДатыJSON.ISO, ВариантЗаписиДатыJSON.ЛокальнаяДатаСоСмещением);

Возврат Время;

КонецФункции

//Обработчики хеширования данных HMAC (SHA-1, MD5, SHA-256, CRC-32) без использования внешних компонент.
//Для получения HMAC в функцию передается первым параметром — ключ K. Второй параметр — сообщение text, которое будет передаваться отправителем и подлинность которого будет проверяться получателем. Третим параметром тип хеш-функции Hash (CRC32, MD5, SHA1, SHA256) . После чего на выходе мы получаем код аутентификации.
// Функция - HMAC
//
// Параметры:                            1
//  K     - ключ    в шестнадцатеричном виде - Строка
//  text - текстовое сообщение - Строка
//  Hash - Hash function (CRC32, MD5, SHA1, SHA256) - Строка
// Возвращаемое значение:
// строка HMAC - Строка
Функция HMAC(Знач K, Знач text, Знач Hash, Кодировка = null) Экспорт
	
	Перем kResult;
	Перем К0;
	
	mKey = K;
	kKey = "";
    Для к = 1 ПО СтрДлина(mKey) Цикл
        
        kKey = kKey + ПреобразоватьДесятичнуюСИВHex(КодСимвола(Сред(mKey,к,1)));
        
	КонецЦикла;
	
	K = kKey;
	
	Если Кодировка = null Тогда Кодировка = КодировкаТекста.UTF8; КонецЕсли;  //++Перминов
	//Если длина ключа K больше размера блока, то к ключу K применяем хэш-функцию
	Если СтрДлина(K)>128 Тогда 
		K = SHA1(K,Hash);
	КонецЕсли;	
	
	//1 Дополняем ключ K нулевыми байтами до размера блока. Размер блока хэш-функции SHA-1 равен 64 байтам.
	StringSHA1 = Лев(K,128);
	Для к = СтрДлина(K) По 128 Цикл
		StringSHA1 = StringSHA1 + "0";
	КонецЦикла;
	К0 = StringSHA1;
	
	//2 Выполняем операцию «побитовое исключающее ИЛИ» c константой 0x36.
	b = ПреобразоватьЧислоВДвоичнуюСИ(ПреобразоватьHexВДесятичнуюСИ("36"));
	
	к = 1;
	Пока к < 128 Цикл
		a             = ПреобразоватьЧислоВДвоичнуюСИ(ПреобразоватьHexВДесятичнуюСИ(Сред(StringSHA1,к,2)));
		с             = XOR(a,b);        
		StringSHA1     = Лев(StringSHA1,к-1)+с+Прав(StringSHA1, 128-к);
		к             = к + 2;
	КонецЦикла;
	
	StringSHA1 = Лев(StringSHA1,128);
	
	//3 Выполняем склейку исходного сообщения со строкой, полученной на шаге 2.
	ДвоичиныйТекст = ПолучитьБуферДвоичныхДанныхИзСтроки(text, Кодировка, ложь);   //++Перминов
	
	//Для к = 1 По СтрДлина(text) Цикл   //--Перминов
	Для к = 0 По ДвоичиныйТекст.Размер - 1 Цикл     //++Перминов
		
		//StringSHA1 = StringSHA1 + ПреобразоватьДесятичнуюСИВHex(КодСимвола(Сред(text,к,1)));   //--Перминов
		StringSHA1 = StringSHA1 + ПреобразоватьДесятичнуюСИВHex(ДвоичиныйТекст[к]);     //++Перминов
		
	КонецЦикла;
	
	//4 Применим хэш-функцию SHA-1 к строке, полученной на прошлом шаге.
	StringSHA1     = SHA1(StringSHA1,Hash);
	kResult     = StringSHA1;
	
	//5 Выполним операцию «побитовое исключающее ИЛИ» c константой 0x5c.
	StringSHA1 = К0;
	
	b = ПреобразоватьЧислоВДвоичнуюСИ(ПреобразоватьHexВДесятичнуюСИ("5c"));
	
	к = 1;
	Пока к < 128 Цикл
		a             = ПреобразоватьЧислоВДвоичнуюСИ(ПреобразоватьHexВДесятичнуюСИ(Сред(StringSHA1,к,2)));
		с             = XOR(a,b);        
		StringSHA1     = Лев(StringSHA1,к-1)+с+Прав(StringSHA1, 128-к);
		к             = к + 2;
	КонецЦикла;
	
	StringSHA1 = Лев(StringSHA1,128);
	
	//6 Склейка строки, полученной на шаге 4, со строкой, полученной на шаге 5.
	StringSHA1 = StringSHA1 + kResult;
	
	//7 Применим хэш-функцию SHA-1 к строке, полученной на прошлом шаге.
	StringSHA1 = SHA1(StringSHA1,Hash);    
	
	Возврат StringSHA1;
	
КонецФункции

Функция SHA1(Знач nString, Hash)    
	Хеширование        = Новый ХешированиеДанных(ХешФункция[Hash]);
	ТипhexBinary    = ФабрикаXDTO.Тип("http://www.w3.org/2001/XMLSchema", "hexBinary");
	ДвоичныеДанные    = ФабрикаXDTO.Создать(ТипhexBinary,nString);
	Хеширование.Добавить(ДвоичныеДанные.Значение);    
	sign             = Хеширование.ХешСумма;
	sign 			 = СтрЗаменить(НРЕГ(sign), " ", "");
	Возврат СтрЗаменить(НРЕГ(sign), " ", "");
КонецФункции

Функция ПреобразоватьДесятичнуюСИВHex(Знач int)	
	Если int < 256 Тогда 
		Возврат Прав("00" + ПреобразоватьДесятичнуюСИВОднобайтовыйHex(int),2);
	Иначе
		Возврат Прав("0000" + ПреобразоватьДесятичнуюСИВДвухбайтовыйHex(int),4);
	КонецЕсли;                                 	
КонецФункции

Функция ПреобразоватьHexВДесятичнуюСИ(Знач hex)
	simbol     = СтрДлина(hex) - 1;
	dec     = 0;
	i         = 1;
	Пока simbol >= 0 Цикл
		simbolHex     = Сред(hex, i, 1);
		Res         = Найти("0123456789abcdef", simbolHex) - 1;
		dec         = dec + Res * Pow(16, simbol);
		simbol         = simbol - 1;
		i             = i + 1;
	КонецЦикла;   
	Возврат dec;
КонецФункции

Функция ПреобразоватьЧислоВДвоичнуюСИ(Знач int, rBit = 8)
	b = "";
	Для k = 1 По rBit Цикл
		m     = pow(2, rBit - k);
		bit = Цел(int / m);
		int = int - m * bit;
		b     = b + bit;
	КонецЦикла;                                
	Возврат b;                                     
КонецФункции

Функция XOR(a, b)    
	res = 0;
	s     = 1;
	к     = Мин(СтрДлина(a), СтрДлина(b));    
	Пока к > 0 Цикл        
		a1     = Сред(a,к,1);
		b1     = Сред(b,к,1);                     
		res = res + s * ?(a1=b1,0,Макс(a1,b1));
		s     = s*2;        
		к     = к-1;        
	КонецЦикла;     
	Возврат ПреобразоватьДесятичнуюСИВHex(res);
КонецФункции

Функция ПреобразоватьДесятичнуюСИВДвухбайтовыйHex(Знач int)	
	BinaryData = ПреобразоватьЧислоВДвоичнуюСИ(int, 11);	
	BinaryData = "110" + Лев(BinaryData,5) + "10" + Прав(BinaryData, 6);	
	DecimalData = ПолучитьДесятичноеЧислоИзДвоичного(BinaryData);	
	HexData = ПреобразоватьДесятичнуюСИВОднобайтовыйHex(DecimalData);	
	Возврат HexData;                                        	
КонецФункции

Функция ПолучитьДесятичноеЧислоИзДвоичного(b)	
	res 	= 0;
	s     	= 1;
	к     	= СтрДлина(b);
	Пока к > 0 Цикл        
		bit   = Сред(b,к,1);
		res = res + s * bit;
		s   = s*2;        
		к   = к-1;        
	КонецЦикла;                              	
	Возврат res;                             	
КонецФункции

Функция ПреобразоватьДесятичнуюСИВОднобайтовыйHex(Знач int)	
	hex = "";
	Пока int <> 0 Цикл
		p   = int % 16;
		hex = Сред("0123456789abcdef", p + 1, 1) + hex;
		int = Цел(int / 16);
	КонецЦикла;
	Возврат hex;                                           	
КонецФункции

// Возвращает перевод значения из РС гф_ПереводЗначенийРеквизитовИСвойств 
//
// Параметры:
//  ИсходноеЗначение - ЛюбаяСсылка, Строка - Объект, на который необходимо получить перевод;
//  Язык - СправочникСсылка.гф_ВидыЯзыков - Язык на который необходимо перевести.
// 	ВозвращатьИсходное - Булево - Если перевод не найден, то будет возвращено исходное значение
// Возвращаемое значение:
//  Строковое значение перевода, если найдено. Если перевод не найден, то при включенном параметре "ВозвращатьИсходное" будет возвращено ИсходноеЗначение
//	Если не включено "ВозвращатьИсходное", то будет возвращено "неопределено"
//
Функция ПолучитьПереводЗначения(ИсходноеЗначение, Язык, ВозвращатьИсходное = Ложь) Экспорт 
	
	ЗначениеПеревода = РегистрыСведений.гф_ПереводЗначенийРеквизитовИСвойств.Получить(Новый Структура("Объект, Язык",ИсходноеЗначение, Язык)).Значение;
	Если ЗначениеЗаполнено(ЗначениеПеревода) Тогда
		Возврат ЗначениеПеревода;
	Иначе
		Если ВозвращатьИсходное Тогда
			Возврат ИсходноеЗначение;
		Иначе
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;
	
КонецФункции

//Функция УбратьЛишниеСимволы(Строка) Экспорт                         //-- Перминов А.С. 26.04.2023 #wortmann #Выгрузка номенклатуры в Wildberries
Функция УбратьЛишниеСимволы(Строка, ТолькоЛатинские = Ложь) Экспорт   //++ Перминов А.С. 26.04.2023 #wortmann #Выгрузка номенклатуры в Wildberries
      
    	НовСтрока = "";
    	ПравильныеСимволы = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnmЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮйцукенгшщзхъфывапролджэячсмитьбю1234567890";
		//<< Перминов А.С. 26.04.2023 #wortmann #Выгрузка номенклатуры в Wildberries
		Если ТолькоЛатинские Тогда
			ПравильныеСимволы = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm";
		КонецЕсли;
		//>> Перминов А.С. 26.04.2023 #wortmann #Выгрузка номенклатуры в Wildberries
		Для Сч = 1 по СтрДлина(Строка) Цикл
    		ТекСимв = Сред(Строка, Сч, 1);
    		Если Найти(ПравильныеСимволы, ТекСимв) > 0 Тогда
    			НовСтрока = НовСтрока + ТекСимв;
    		КонецЕсли;
    	КонецЦикла;
    	Возврат НовСтрока;

КонецФункции

Функция ВернутьЦифрыИзСтроки(Знач СтрокаПроверки) Экспорт
    
    Если ТипЗнч(СтрокаПроверки) <> Тип("Строка") Тогда
        Возврат "";
    КонецЕсли;
    
    ЦифрыИзСтроки = "";
    
    Для сч = 1 По СтрДлина(СтрокаПроверки) Цикл
        Символ = Сред(СтрокаПроверки, сч, 1);
        Если ЭтоЦифра(Символ) Тогда
            ЦифрыИзСтроки = ЦифрыИзСтроки + Символ;
        КонецЕсли;
    КонецЦикла;
        
    Возврат ЦифрыИзСтроки;
    
КонецФункции

Функция ЭтоЦифра(Символ) Экспорт
	
    КодСимвола = КодСимвола(Символ);
    Возврат (КодСимвола >= 48 И КодСимвола <= 57);
	
КонецФункции

Функция ПреобразоватьМиллиметрыВСантиметрыИзСтроки(Значение, ОкруглятьДоЦелого = Ложь) Экспорт
	
	ПустоеЗначение = "";

	Если ЗначениеЗаполнено(Значение) Тогда
		
		СтрокаЧисло = ВернутьЦифрыИзСтроки(Значение);
		Попытка
			Число_мм = Число(СтрокаЧисло);         //В свойстве высота в мм
		Исключение
			Число_мм = 0;
		КонецПопытки;
		Если Число_мм > 0 Тогда
			Число_см = Число_мм/10;                //Переводим в см
			Возврат Формат(?(ОкруглятьДоЦелого,ОКР(Число_см),Число_см), "ЧГ=0");      //Преобразуем в строку
		КонецЕсли;
	КонецЕсли;
	
	Возврат ПустоеЗначение;
	
КонецФункции

Функция ПолучитьАртикулПродавца(ВнешняяСистема, АртикулНоменклатуры, Коллекция ,РазмерНоменклатуры = "", ИспользуютсяХарактеристики = Ложь,  ВариантУПП = Ложь) Экспорт
	
	Если ВнешняяСистема = ПредопределенноеЗначение("Перечисление.гф_ВнешниеСистемы.Lamoda") Тогда
		Если ИспользуютсяХарактеристики Тогда
			Если ВариантУПП Тогда
				Если ЗначениеЗаполнено(Коллекция) и ТипЗнч(Коллекция) = Тип("СправочникСсылка.КоллекцииНоменклатуры") Тогда
					КодКоллекция = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Коллекция, "Код");
					КодКоллекция = СтрЗаменить(СтрЗаменить(КодКоллекция, " ", "_"), Символы.НПП, "_");
				Иначе
					КодКоллекция = "";
				КонецЕсли;
				Артикул = СтрЗаменить(АртикулНоменклатуры, ",","_");
				Возврат ?(ЗначениеЗаполнено(КодКоллекция),КодКоллекция+"_","")+Артикул+?(ЗначениеЗаполнено(РазмерНоменклатуры),"/"+РазмерНоменклатуры,"");
			Иначе
				Возврат СтрЗаменить(АртикулНоменклатуры+?(ЗначениеЗаполнено(РазмерНоменклатуры),"#"+РазмерНоменклатуры,""),",","."); 
			КонецЕсли;
		Иначе
			Если ВариантУПП Тогда
				Возврат СтрЗаменить(АртикулНоменклатуры, ",","_");
			Иначе
				Возврат СтрЗаменить(АртикулНоменклатуры, ",",".");
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли ВнешняяСистема = ПредопределенноеЗначение("Перечисление.гф_ВнешниеСистемы.Wildberries") Тогда
		Возврат СтрЗаменить(АртикулНоменклатуры, ",",".");		
	ИначеЕсли ВнешняяСистема = ПредопределенноеЗначение("Перечисление.гф_ВнешниеСистемы.Cactus") Тогда
		Если ИспользуютсяХарактеристики Тогда
			Возврат СтрЗаменить(АртикулНоменклатуры+?(ЗначениеЗаполнено(РазмерНоменклатуры),"#"+РазмерНоменклатуры,""),",",".");	
		Иначе
			Возврат СтрЗаменить(АртикулНоменклатуры, ",",".");
		КонецЕсли;
	Иначе
		Возврат СтрЗаменить(АртикулНоменклатуры, ",", ".");
	КонецЕсли;
	
КонецФункции  

//<< Перминов А.С. 17.07.2023 Настройки через привелигированный режим
Функция ПолучитьОбщиеНастройки(ИмяОбработки, КлючНастроек, ОписаниеНастроек, Пользователь) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Соответствие = ХранилищеОбщихНастроек.Загрузить(ИмяОбработки, КлючНастроек, ОписаниеНастроек, Пользователь);
	
	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат Соответствие;
	
КонецФункции

Функция СохранитьОбщиеНастройки(ИмяОбработки, КлючНастроек, СоответствиеНастроек, ОписаниеНастроек, Пользователь) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
		ХранилищеОбщихНастроек.Сохранить(ИмяОбработки, КлючНастроек, СоответствиеНастроек, ОписаниеНастроек, Пользователь); 
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецФункции
//>> Перминов А.С. 17.07.2023 