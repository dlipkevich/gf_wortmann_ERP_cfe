﻿
Перем НаПринтер;

Процедура ЗадатьОформление(область, ОформлениеПоля)
	//Если ОформлениеПоля.АвтоОтступ.Использование Тогда
	//	область.АвтоОтступ = ОформлениеПоля.АвтоОтступ.Значение;
	//КонецЕсли;
	//Если ОформлениеПоля.ВертикальноеПоложение.Использование Тогда
	//	область.ВертикальноеПоложение = ОформлениеПоля.ВертикальноеПоложение.Значение;
	//КонецЕсли;
	//Если ОформлениеПоля.ВыделятьОтрицательные.Использование Тогда
	//	область.ВыделятьОтрицательные = ОформлениеПоля.ВыделятьОтрицательные.Значение;
	//КонецЕсли;
	//Если ОформлениеПоля.ГоризонтальноеПоложение.Использование Тогда
	//	область.ГоризонтальноеПоложение = ОформлениеПоля.ГоризонтальноеПоложение.Значение;
	//КонецЕсли;
	//Если ОформлениеПоля.ОриентацияТекста.Использование Тогда
	//	область.ОриентацияТекста = ОформлениеПоля.ОриентацияТекста.Значение;
	//КонецЕсли;
	//Если ОформлениеПоля.Отступ.Использование Тогда
	//	область.Отступ = ОформлениеПоля.Отступ.Значение;
	//КонецЕсли;
	//Если ОформлениеПоля.Текст.Использование Тогда
	//	область.Текст = ОформлениеПоля.Текст.Значение;
	//КонецЕсли;
	//Если ОформлениеПоля.Формат.Использование Тогда
	//	область.Формат = ОформлениеПоля.Формат.Значение;
	//КонецЕсли;
	//Если ОформлениеПоля.ЦветТекста.Использование Тогда
	//	область.ЦветТекста = ОформлениеПоля.ЦветТекста.Значение;
	//КонецЕсли;
	//Если ОформлениеПоля.ЦветФона.Использование Тогда
	//	область.ЦветФона = ОформлениеПоля.ЦветФона.Значение;
	//КонецЕсли;
	//Если ОформлениеПоля.Шрифт.Использование Тогда
	//	область.Шрифт = ОформлениеПоля.Шрифт.Значение;
	//КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Гандзюк Е. 2012.01.26
//
&НаКлиенте
Процедура ОсновныеДействияФормыEAC_ПечатьA1(Команда)
	
	ТабДок = ПечатьЭтикетки(Ложь);
	
    КоллекцияПечатныхФорм = УправлениеПечатьюКлиент.НоваяКоллекцияПечатныхФорм("ПечатьЭтикетокWortman");
    ПечатнаяФорма = УправлениеПечатьюКлиент.ОписаниеПечатнойФормы(КоллекцияПечатныхФорм, "ПечатьЭтикетокWortman");
    ПечатнаяФорма.СинонимМакета = "ПечатьЭтикетокWortman";
    ПечатнаяФорма.ТабличныйДокумент = ТабДок;
    ПечатнаяФорма.ИмяФайлаПечатнойФормы = "ПечатьЭтикетокWortman";
	
	ДополнительныеПараметры = Новый Структура("ВладелецФормы", ЭтотОбъект);
    ОбластиОбъектов = Новый СписокЗначений;
    УправлениеПечатьюКлиент.ПечатьДокументов(КоллекцияПечатныхФорм, ОбластиОбъектов, ДополнительныеПараметры);
	
КонецПроцедуры

&НаСервере
Функция ПолучитьМакетНаСервере(ИмяМакета)
	ОбъектДок = РеквизитФормыВЗначение("Объект"); 
	Макет = ОбъектДок.ПолучитьМакет(ИмяМакета);
	Возврат Макет;
КонецФункции

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	ОрганизацияПриИзмененииНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ОрганизацияПриИзмененииНаСервере()
	
	СведенияПоОрганизации = ФормированиеПечатныхФорм.СведенияОЮрФизЛице(Объект.Организация, ?(ЗначениеЗаполнено(Объект.СсылкаНаОбъект), Объект.СсылкаНаОбъект.Дата, ТекущаяДата())) ;
	Объект.Адрес = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияПоОрганизации,"ЮридическийАдрес") ; 
	
	
КонецПроцедуры


&НаСервере
Функция ПечатьЭтикетки(НаПринтерЭтикеток=Ложь)
	
	Перем ТекущийАртикул;
	Перем Производитель;
	Перем АдресПроизводителя;
	Перем Декларация;
	
	//(н)Галфинд/Сефербеков 08.03.2024 ( 
	//Создаем свое ТЗ  НастройкаПолей с колонками Заголовок и Поле и заполняем его один раз вначале. 
	
	//1. Торговая марка - берется из доп.сведения Brand_name
	//2. Производитель  - Из реквизита ОсновнойПоставщик Номенклатуры
	//3. Импортер - Организация
	//4. Изготовитель - Из реквизита СтранаПроисхождения Номенклатуры 
	//5. Артикул - Из реквизита Артикул Номенклатуры 
	//6. Наименование - Из реквизита НаименованиеПолное Номенклатуры 
	//7. Цвет - из доп.сведения Color_Name
	//8. Материла верха - из доп.сведения Material
	//9. Декларация - из справочника W настройки (элемент Свойство Код деларации), в принципе это тоже доп.свойство-сведение Номекклатуры, почему то В УПП реализовано через промежуточный справочник   
	//10. Цена опт. Без НДС - Из Регистра сведений ЦеныНоменклатуры по номенклатуре и цене оптовой указанной на форме 
	//11. РРЦ - Из Регистра сведений ЦеныНоменклатуры по номенклатуре и цене розничной указанной на форме 

	ПечатьЕАС = Истина ;
	
	ВнешняяКомпонента 			= ПодключитьВнешнююКомпонентуПечатиШтрихкода();
	
	СоответствиеПоставщиков = новый Соответствие;
	ДеревоТовары = ПолучитьДеревоДанныхДекларация2();
	
	//Если Не ПроверитьЗаполнениеНеобходимыхДанных(ДеревоТовары) Тогда
	//	Возврат
	//КонецЕсли;
	
	МакетАртикул = ПолучитьМакетНаСервере("Артикул").ПолучитьОбласть("Заголовок");
	ГраницаМакета = 14;
	КоличествоСтрок = 7;
	КоличествоКолонок = 3;
	ИндексЭтикетки = 0;
	
	ТД = Новый ТабличныйДокумент;
	ИндексСтроки = 1;
	ИндексКолонки = 1;
	
	//запрос = новый Запрос(
	//"ВЫБРАТЬ
	//|	выборка.Ссылка,
	//|	выборка.ХранилищеНастроек
	//|ИЗ
	//|	Справочник.СохраненныеНастройки КАК выборка
	//|ГДЕ
	//|	выборка.ТипНастройки = ЗНАЧЕНИЕ(Перечисление.ТипыНастроек.ПроизвольныеНастройки)
	//|	И выборка.НастраиваемыйОбъект = ""ПечатьЭтикеток.Соответствия""");
	//выборка = запрос.Выполнить().Выбрать();
	//Если выборка.Следующий() Тогда
	//	СоответствиеНастроек = новый Соответствие;
	//	НастрокиСоответствия = выборка.ХранилищеНастроек.Получить();
	//	Для каждого строка Из НастрокиСоответствия Цикл
	//		СоответствиеНастроек.Вставить(строка.ВидНоменклатуры, строка.Настройка);
	//	КонецЦикла;
	//Иначе
	//	ВызватьИсключение "Не заданы настройки этикеток для печати!";
	//КонецЕсли;
	
	Свойство_GLN_manufacturer = НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураGLN_Manufacturer") ;
	Свойство_Material_Surface = НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураMaterialSurface");
	Свойство_Material_Lining = НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураMaterialLining");
	Свойство_Material_Bottom = НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураMaterialBottom");
	Свойство_АдресПроизводителя = НайтиДополнительныйРеквизитПоИдентификатору("гф_АдресПроизводителя");  
	//Свойство_Сезон = НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураMaterialBottom");
	Свойство_Сезон = Неопределено ;
	Свойство_Декларация =  НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураДекларация") ;
	
	Макет = ПолучитьМакетНаСервере("Этикетка_Декларация2");
	
	выборка = Объект.товары.НайтиСтроки(новый Структура("Пометка", Истина));
	
	// пока непонятно откуда полуцчить, формируем фкисрованную настройку(ТЗ)
	НастройкаПолей = СформироватьТЗПолей() ;
	////////////////////////
	
	//Данные организации
	СведенияПоОрганизации = ФормированиеПечатныхФорм.СведенияОЮрФизЛице(Объект.Организация, Объект.СсылкаНаОбъект.Дата) ;
	АдресОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияПоОрганизации,"ЮридическийАдрес") ; 
			
	Для Каждого строка Из выборка Цикл
		//ОбработкаПрерыванияПользователя();
		
		Номенклатура = строка.Номенклатура;
		Если Объект.АртикулыОтдельно Тогда
			 Если не ТекущийАртикул = строка.АртикулУпаковки Тогда
				 Если не ТекущийАртикул = Неопределено Тогда
					 ТД.ВывестиГоризонтальныйРазделительСтраниц();
				 КонецЕсли;
				 ТекущийАртикул = строка.АртикулУпаковки;
				 ИндексСтроки = 1;
				 ИндексКолонки = 1;
				 МакетАртикул.Параметры.Заполнить(новый Структура("Артикул, Клиент", ТекущийАртикул, Объект.Контрагент ));
				 ТД.Вывести(МакетАртикул);
			 КонецЕсли;
		КонецЕсли;
		
		ОписаниеТовара = Строка(Номенклатура) + " (" + строка.Артикул + ")";
		//Состояние("Печать этикеток для номенклатуры " + ОписаниеТовара + "...");
		
		нашли = ДеревоТовары.строки.Найти(Номенклатура);
		Если нашли = Неопределено Тогда
			сообщить("" + Номенклатура + " не найдены свойства для печати этикетки!", СтатусСообщения.Важное);
			Продолжить;
		Иначе
			таб = нашли.Строки;
		КонецЕсли;
		таб.Сортировать("Свойство");
		
		//// таблица настройки полей
		//Соответствие = ПолучитьСоответствие(Номенклатура.ВидНоменклатуры, СоответствиеНастроек);
		//Если Соответствие = Неопределено Тогда
		//	Продолжить;
		//Иначе
		//	настройка = Соответствие.ХранилищеНастроек.Получить();
		//КонецЕсли;
		
		//Если ТипЗнч(настройка) = Тип("Структура") Тогда
		//	ПечататьЕАС = настройка.ПечататьЕАС;
		//	НастройкаПолей = настройка.СписокПолей;
		//ИначеЕсли ТипЗнч(настройка) = Тип("ТаблицаЗначений") Тогда
		//	ПечататьЕАС = Истина;
		//	НастройкаПолей = настройка;
		//КонецЕсли;
		
		Если не ПечатьЕАС Тогда
			ОбластьОсновная = Макет.ПолучитьОбласть("ОбластьОсновная2");
			ОбластьОсновная.Рисунки.Очистить();
			Описание = "";
		ИначеЕсли Не ЗначениеЗаполнено(строка.СерияНоменклатуры) ИЛИ строка.СерияНоменклатуры.ЛИТ_КМ.Пустая() Тогда
			ОбластьОсновная = Макет.ПолучитьОбласть("ОбластьОсновная");
		Иначе
			ОбластьОсновная = Макет.ПолучитьОбласть("ОбластьОсновная1");
			//ОбластьОсновная.Рисунки.Штрихкод.Объект.barcode = СтрЗаменить(строка.СерияНоменклатуры.ЛИТ_КМ.КМ, "*", символ(29));
			
			КМ = строка.СерияНоменклатуры.ЛИТ_КМ.КМ;
			Штрихкод = символ(01) + СтрЗаменить(КМ, " ", символ(29));
			ПараметрыШтрихкода = новый Структура("ТипКода, Штрихкод, Ширина, Высота, ПрозрачныйФон, ОтображатьТекст",
			19, Штрихкод, 100, 100, Истина, Ложь);
			картинка = ПолучитьКартинкуШтрихкода(ВнешняяКомпонента, ПараметрыШтрихкода);
			
			РисунокШтрихкод = ОбластьОсновная.Рисунки.Штрихкод;
			РисунокШтрихкод.Высота = 33;
			РисунокШтрихкод.Ширина = 33;
			РисунокШтрихкод.Картинка = картинка;
		КонецЕсли;
		ОбластьОписание = Макет.ПолучитьОбласть("ОбластьОписание");
		
		// адрес производителя 
		АдресПроизводителя = "" ;
		строкаДопСвойстваАдресПроизводителя = таб.Найти(Свойство_АдресПроизводителя, "Свойство");
		Если строкаДопСвойстваАдресПроизводителя <> Неопределено Тогда
			АдресПроизводителя = строкаДопСвойстваАдресПроизводителя.Значение ;
		КонецЕсли;
					
		// декларация
		нашли = таб.Найти(Свойство_Декларация, "Свойство");
		Если не нашли = Неопределено Тогда
			Декларация = нашли.Значение;
		Иначе
			нашли = таб.Найти(Свойство_Material_Surface, "Свойство");
			Если не нашли = Неопределено Тогда
				Декларация = нашли.Значение + " " + Номенклатура;
			Иначе
				Декларация = строка(Номенклатура);
			КонецЕсли;
			
			нашли = таб.Найти(Свойство_Сезон, "Свойство");
			Если не нашли = Неопределено Тогда
				Декларация = сокрЛП(СтрЗаменить(Декларация, нашли.Значение, ""));
			КонецЕсли;
			
			Декларация = гф_МодульИнтеграцияСВнешнимиСистемами.ПолучитьПереводЗначения(Декларация, Справочники.гф_ВидыЯзыков.Russian, Истина) ; 
			//Декларация = Переводчик.ПолучитьПереводОбъекта(Декларация, Справочники.RC_Язык.Russian);
			//Декларация = Обработки.RC_ДиспетчерПереводов.ПолучитьПереводОбъекта(Декларация, Справочники.RC_Язык.Russian);
			//Декларация = Перевод(Декларация, Справочники.RC_Язык.Russian);
		КонецЕсли;
		
		// обход полей
		ЕстьОписание = Ложь;
		СтрокаОписание = Неопределено;
		ЗначениеОписание = Неопределено;
		Граница = мин(НастройкаПолей.Количество(), ГраницаМакета);
		Для а=1 По Граница Цикл
			//ОбработкаПрерыванияПользователя();
			
			значение = "";
			СтрокаНастройки = НастройкаПолей[а-1];
			
			//нашли = СписокПолей.Найти(СтрокаНастройки.Поле);
			нашли = НЕопределено; 
			Если не нашли = Неопределено Тогда
				значение = нашли.Текст;
				
			ИначеЕсли СтрокаНастройки.Поле = "Производитель" Тогда
				Производитель = Неопределено;
				Если не Номенклатура.Производитель.Пустая() Тогда
					Производитель = Номенклатура.Производитель;
				Иначе
					нашли = таб.Найти(Свойство_GLN_manufacturer, "Свойство");
					Если не нашли = Неопределено Тогда
						Производитель = Справочники.Контрагенты.НайтиПоРеквизиту("RC_GLN_номер", нашли.Значение);
					КонецЕсли;
				КонецЕсли;
								
				значение = Производитель;
				
			ИначеЕсли СтрокаНастройки.Поле = "Адрес производителя" Тогда
				значение = АдресПроизводителя;
				
			ИначеЕсли СтрокаНастройки.Поле = "Адрес основного поставщика" Тогда
				значение = "";
				ОсновнойПоставщик = Номенклатура.ОсновнойПоставщик;
				Если не ОсновнойПоставщик.Пустая() Тогда
					значение = СоответствиеПоставщиков.Получить(ОсновнойПоставщик);
					Если значение = Неопределено Тогда
						значение = "";
						СведенияО = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(ОсновнойПоставщик, ТекущаяДата());
						СведенияО.Свойство("ЮридическийАдрес", значение);
						СоответствиеПоставщиков.Вставить(ОсновнойПоставщик, значение);
					КонецЕсли;
				КонецЕсли;
				
			ИначеЕсли СтрокаНастройки.Поле = "Импортер" Тогда
				Если Объект.ВзятьАдресОрганизации = "ВзятьАдресОрганизции" Тогда
					значение = Объект.Организация;
				Иначе
					значение = Производитель;
				КонецЕсли;
				
			ИначеЕсли СтрокаНастройки.Поле = "Адрес импортера" Тогда
				Если Объект.ВзятьАдресОрганизации = "ВзятьАдресОрганизции" Тогда
					значение = Объект.Адрес;
				Иначе
					значение = АдресПроизводителя;
				КонецЕсли;
				
			ИначеЕсли СтрокаНастройки.Поле = "Декларация о соответствии" Тогда
				значение = Декларация;
				
			ИначеЕсли Найти(СтрокаНастройки.Поле, "ДополнительноеОписание") > 0 Тогда
				ЕстьОписание = Истина;
				СтрокаОписание = СтрокаНастройки;
				ЗначениеОписание = Номенклатура[СтрокаНастройки.Поле];
				Продолжить;
				
			ИначеЕсли СтрокаНастройки.Поле = "ЦенаОптовая" Тогда
				//+++ БФ Бобнев К.С. 09.04.24
				//значение = НайтиЦенуПоТипу(Номенклатура, Объект.ТипЦенОптовая);
				нашли = таб.Найти(Объект.ТипЦенОптовая, "Свойство");
				Если нашли <> Неопределено Тогда
					значение = нашли.Значение;
				КонецЕсли;
				//--- БФ Бобнев К.С. 09.04.24
			ИначеЕсли СтрокаНастройки.Поле = "ЦенаРозничная" Тогда
				//+++ БФ Бобнев К.С. 09.04.24
				//значение = НайтиЦенуПоТипу(Номенклатура, Объект.ТипЦенРозничная);
				нашли = таб.Найти(Объект.ТипЦенРозничная, "Свойство");
				Если нашли <> Неопределено Тогда
					значение = нашли.Значение;
				КонецЕсли;
				//--- БФ Бобнев К.С. 09.04.24
			ИначеЕсли  СтрокаНастройки.Поле = "ОсновнойПоставщик" Тогда
				//+++ БФ Бобнев К.С. 09.04.24
				//значение =  АдресПроизводителя ;
				значение = Номенклатура.Производитель;
				//--- БФ Бобнев К.С. 09.04.24
			ИначеЕсли ТипЗнч(СтрокаНастройки.Поле) = Тип("Строка") Тогда
				значение = Номенклатура[СтрокаНастройки.Поле];
				
			Иначе
				Если СтрокаНастройки.Поле = Свойство_GLN_manufacturer Тогда
					значение = Производитель;
					
				//ИначеЕсли ИзменитьМатериалВерх и СтрокаНастройки.Поле = Свойство_Material_Surface Тогда
				//	значение = МатериалВерх;
				//	
				//ИначеЕсли ИзменитьМатериалПодкладка и СтрокаНастройки.Поле = Свойство_Material_Lining Тогда
				//	значение = МатериалПодкладка;
				//	
				//ИначеЕсли ИзменитьМатериалПодошва и СтрокаНастройки.Поле = Свойство_Material_Bottom Тогда
				//	значение = МатериалПодошва;
					
				Иначе
					нашли = таб.Найти(СтрокаНастройки.Поле, "Свойство");
					Если не нашли = Неопределено Тогда
						значение = нашли.Значение;
						Если ТипЗнч(значение) = Тип("Строка") Тогда
							//значение = Переводчик.ПолучитьПереводОбъекта(Значение, Справочники.RC_Язык.Russian);
							значение = гф_МодульИнтеграцияСВнешнимиСистемами.ПолучитьПереводЗначения(значение, Справочники.гф_ВидыЯзыков.Russian, Истина) ; 
							
							//значение = Обработки.RC_ДиспетчерПереводов.ПолучитьПереводОбъекта(Значение, Справочники.RC_Язык.Russian);
							//значение = Перевод(Значение, Справочники.RC_Язык.Russian);
							значение = Значение ;
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			
			Если ПечатьЕАС Тогда
				ОбластьОсновная.Параметры["Поле" + а] = СтрокаНастройки.Заголовок;
				ОбластьОсновная.Параметры["Значение" + а] = значение;
				
				//Если ЗначениеЗаполнено(СтрокаНастройки.Маска) Тогда
				//	область = ОбластьОсновная.Область("R"+(а+1)+"C3");
				//	область.Маска = СтрокаНастройки.Маска;
				//	ОбластьОсновная.Параметры["Значение" + а] = сред(значение, 1, СтрДлина(СтрокаНастройки.Маска));
				//ИНаче
				//	ОбластьОсновная.Параметры["Значение" + а] = значение;
				//КонецЕсли;
				//
				////заголовок
				//Если ЗначениеЗаполнено(СтрокаНастройки.ОформлениеЗаголовка) Тогда
				//	ЗадатьОформление(ОбластьОсновная.Область("R"+(а+1)+"C2"), СтрокаНастройки.ОформлениеЗаголовка);
				//	Если СтрокаНастройки.ОформлениеЗаголовка.Текст.Использование Тогда
				//		ОбластьОсновная.Параметры["Поле" + а] = СтрокаНастройки.ОформлениеЗаголовка.Текст.Значение;
				//	КонецЕсли;
				//КонецЕсли;
				////значение
				//Если ЗначениеЗаполнено(СтрокаНастройки.ОформлениеПоля) Тогда
				//	ЗадатьОформление(ОбластьОсновная.Область("R"+(а+1)+"C3"), СтрокаНастройки.ОформлениеПоля);
				//	Если СтрокаНастройки.ОформлениеПоля.Текст.Использование Тогда
				//		ОбластьОсновная.Параметры["Значение" + а] = СтрокаНастройки.ОформлениеПоля.Текст.Значение;
				//	КонецЕсли;
				//КонецЕсли;
				Если СтрокаНастройки.Поле = "Артикул" Тогда
					ОбластьОсновная.Область("R"+(а+1)+"C3").Шрифт = Новый Шрифт(ОбластьОсновная.Область("R"+(а+1)+"C3").Шрифт,, 9);
				КонецЕсли;
											
			Иначе
				поле = СтрокаНастройки.Заголовок;
				Если ЗначениеЗаполнено(СтрокаНастройки.Маска) Тогда
					Значение = формат(сред(значение, 1, СтрДлина(СтрокаНастройки.Маска)), СтрокаНастройки.Маска);
				ИНаче
					Значение = значение;
				КонецЕсли;
				
				Описание = Описание + ?(Описание = "", "", Символ(13)) + поле + ": " + Значение; 
			КонецЕсли;
		КонецЦикла;
		
		Если не ПечатьЕАС Тогда
			ОбластьОсновная.Параметры["Описание"] = Описание;
		КонецЕсли;
		
		Для ИндексЭтикетки = 1 По строка.КоличествоЭтикеток Цикл
			Если  ИндексСтроки > (КоличествоСтрок - 1) тогда  //т.к. на листе 7 строк, первая из них - заголовок
				ИндексСтроки = ИндексСтроки - (КоличествоСтрок - 1);
			КонецЕсли;
			
			Если ИндексКолонки = 1 Или НаПринтерЭтикеток Тогда
				ТД.Вывести(ОбластьОсновная);
			Иначе	
				ТД.Присоединить(ОбластьОсновная);
			КонецЕсли;
			
			ИндексКолонки = ?(НаПринтерЭтикеток, 1, ?(ИндексКолонки = КоличествоКолонок, 1 , ИндексКолонки + 1));
			ИндексСтроки = ?(НаПринтерЭтикеток, ИндексСтроки + 1, ?(ИндексКолонки = КоличествоКолонок, ИндексСтроки + 1, ИндексСтроки));
		КонецЦикла;
		
		Если ЕстьОписание и ТипЗнч(ЗначениеОписание) = Тип("Строка") и ЗначениеОписание > "" Тогда
			ОбластьОписание.Параметры.Артикул = строка.Артикул;
			ОбластьОписание.Параметры.Описание = УбратьПустыеСтроки(ЗначениеОписание);
			
			Если ЗначениеЗаполнено(СтрокаОписание.ОформлениеПоля) Тогда
				область = ОбластьОписание.Область("R3C3:R15C3");
				ЗадатьОформление(область, СтрокаОписание.ОформлениеПоля);
			КонецЕсли;
			
			Для ИндексЭтикетки = 1 По строка.КоличествоЭтикеток Цикл
				Если  ИндексСтроки > (КоличествоСтрок - 1) тогда  //т.к. на листе 7 строк, первая из них - заголовок
					ИндексСтроки = ИндексСтроки - (КоличествоСтрок - 1);
				КонецЕсли;
				
				Если ИндексКолонки = 1 Или НаПринтерЭтикеток Тогда
					ТД.Вывести(ОбластьОписание);
				Иначе	
					ТД.Присоединить(ОбластьОписание);
				КонецЕсли;
				
				ИндексКолонки = ?(НаПринтерЭтикеток, 1, ?(ИндексКолонки = КоличествоКолонок, 1 , ИндексКолонки + 1));
				ИндексСтроки = ?(НаПринтерЭтикеток, ИндексСтроки + 1, ?(ИндексКолонки = КоличествоКолонок, ИндексСтроки + 1, ИндексСтроки));
			КонецЦикла;
			
			ЕстьОписание = Ложь;
			СтрокаОписание = Неопределено;
			ЗначениеОписание = Неопределено;
		КонецЕсли;
	КонецЦикла;
	
	ТД.РазмерСтраницы = "A4";
	ТД.ПолеСверху = 0; ТД.ПолеСнизу = 0; ТД.ПолеСлева = 0; ТД.ПолеСправа = 0;
	ТД.АвтоМасштаб = Истина;
	ТД.КоличествоЭкземпляров = 1;
	ТД.Защита = Истина;
	ТД.ПолеСлева = 2;
	ТД.ТолькоПросмотр = Ложь;
	ТД.ОтображатьСетку = Ложь;
	ТД.ОтображатьЗаголовки = Ложь;
	ТД.КлючПараметровПечати = "Печать этикеток";
	//УниверсальныеМеханизмы.НапечататьДокумент(ТД,,, "Печать этикеток");
	
	Возврат ТД ;
	
КонецФункции

Функция НайтиДополнительныйРеквизитПоИдентификатору(ИдентификаторСвойства)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДополнительныеРеквизитыИСведения.Ссылка КАК Ссылка
		|ИЗ
		|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДополнительныеРеквизитыИСведения
		|ГДЕ
		|	ДополнительныеРеквизитыИСведения.ИдентификаторДляФормул = &ИдентификаторДляФормул";
	
	Запрос.УстановитьПараметр("ИдентификаторДляФормул", ИдентификаторСвойства);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка.Следующий();
		Возврат Выборка.Ссылка;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция СформироватьТЗПолей()
	
	СоответствиеПорядокПолей = СформироватьСоответствиеПорядокПолей();
	
	СоответствиеПолей = Новый Соответствие(); 
	СоответствиеПолей.Вставить(НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураBrand_Name"), "Тороговая марка"); 
	СоответствиеПолей.Вставить("ОсновнойПоставщик",	"Производитель"); 
	СоответствиеПолей.Вставить("Импортер", "Импортер");
	
	СоответствиеПолей.Вставить("СтранаПроисхождения", "Изготовитель");
	СоответствиеПолей.Вставить("Артикул",	"Артикул");
	СоответствиеПолей.Вставить("НаименованиеПолное", "Наименование");
	СоответствиеПолей.Вставить(НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураColor_Name"), 	"Цвет");
	//+++ БФ Бобнев К.С. 09.04.24
	//СоответствиеПолей.Вставить(НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураMaterial"), 	"Материал верха");
	СоответствиеПолей.Вставить(НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураMaterialSurface"), 	"Материал верха");
	//--- БФ Бобнев К.С. 09.04.24
	СоответствиеПолей.Вставить("Декларация о соответствии",	"Декларация");
	СоответствиеПолей.Вставить("ЦенаОптовая",	"Цена опт. без НДС");
	СоответствиеПолей.Вставить("ЦенаРозничная",	"РРЦ");
	
	НастройкаПолей = Новый ТаблицаЗначений ;
	НастройкаПолей.Колонки.Добавить("Поле");
	НастройкаПолей.Колонки.Добавить("Заголовок");
	НастройкаПолей.Колонки.Добавить("Порядок",  ОбщегоНазначенияУТ.ПолучитьОписаниеТиповЧисла(2, 0) );
	
	Для каждого элемент Из СоответствиеПолей Цикл
		НоваяСтрока = НастройкаПолей.Добавить();
		НоваяСтрока.Поле  = элемент.Ключ ;
		НоваяСтрока.Заголовок  = элемент.Значение ;
		НоваяСтрока.Порядок = СоответствиеПорядокПолей[НоваяСтрока.Поле] ;
	КонецЦикла;
	
	НастройкаПолей.Сортировать("Порядок"); 
	Возврат НастройкаПолей ;
	
КонецФункции

Функция СформироватьСоответствиеПорядокПолей()
	
	СоответствиеПолей = Новый Соответствие(); 
	СоответствиеПолей.Вставить(НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураBrand_Name"), 1); 
	СоответствиеПолей.Вставить("ОсновнойПоставщик",	2); 
	СоответствиеПолей.Вставить("Импортер", 3);
	
	СоответствиеПолей.Вставить("СтранаПроисхождения", 4);
	СоответствиеПолей.Вставить("Артикул",	5);
	СоответствиеПолей.Вставить("НаименованиеПолное", 6);
	СоответствиеПолей.Вставить(НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураColor_Name"), 	7);
	//+++ БФ Бобнев К.С. 09.04.24
	//СоответствиеПолей.Вставить(НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураMaterial"), 	8);
	СоответствиеПолей.Вставить(НайтиДополнительныйРеквизитПоИдентификатору("гф_НоменклатураMaterialSurface"), 	8);
	//--- БФ Бобнев К.С. 09.04.24
	СоответствиеПолей.Вставить("Декларация о соответствии",	9);
	СоответствиеПолей.Вставить("ЦенаОптовая",	10);
	СоответствиеПолей.Вставить("ЦенаРозничная",	11);
		
	Возврат СоответствиеПолей ;
	
КонецФункции

Функция НайтиЦенуПоТипу(Номенклатура, ВидЦены)
	
	запрос = новый Запрос;
	Запрос.Текст = "
	|	ВЫБРАТЬ
	|	а.ВидЦены КАК ВидЦены,
	|	а.Номенклатура КАК Номенклатура,
	|	а.Цена КАК Цена
	|ИЗ
	|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&ДатаСреза ,
	|			Номенклатура = &Номенклатура
	|				И ВидЦены = &ВидЦены) КАК а" ;
	
	запрос.УстановитьПараметр("ДатаСреза", Объект.СсылкаНаОбъект.Дата);
	запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	запрос.УстановитьПараметр("ВидЦены", ВидЦены);
	выборка = запрос.Выполнить().Выбрать();
	
	Если выборка.Следующий() Тогда
		возврат выборка.Цена;
	Иначе
		возврат 0;
	КонецЕсли;
	
КонецФункции // НайтиЦенуПоТипу()

Функция ПолучитьДеревоДанныхДекларация2(Параметры = Неопределено) 
	
	Запрос = Новый Запрос ;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Т.Номенклатура КАК Номенклатура
		|ПОМЕСТИТЬ Товары
		|ИЗ
		|	&Товары КАК Т
		|ГДЕ
		|	Т.Пометка
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Т.Номенклатура КАК Номенклатура,
		|	НоменклатураДополнительныеРеквизиты.Свойство КАК Свойство,
		|	НоменклатураДополнительныеРеквизиты.Значение КАК Значение
		|ИЗ
		|	Товары КАК Т
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура.ДополнительныеРеквизиты КАК НоменклатураДополнительныеРеквизиты
		|		ПО Т.Номенклатура = НоменклатураДополнительныеРеквизиты.Ссылка
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ДополнительныеСведения.Объект,
		|	ДополнительныеСведения.Свойство,
		|	ДополнительныеСведения.Значение
		|ИЗ
		|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
		|ГДЕ
		|	ДополнительныеСведения.Объект В(Выбрать Товары.Номенклатура Из Товары Как Товары)
		|
		//+++ БФ Бобнев К.С. 09.04.24
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ЦеныНоменклатуры.Номенклатура,
		|   ЦеныНоменклатуры.ВидЦены,
		|   ЦеныНоменклатуры.Цена
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры25.СрезПоследних(&ДатаСреза ,
		|			Номенклатура В(Выбрать Товары.Номенклатура Из Товары Как Товары)
		|				И (ВидЦены = &ВидЦенОптовый ИЛИ ВидЦены = &ВидЦенРозничный)) КАК ЦеныНоменклатуры
		|
		//--- БФ Бобнев К.С. 09.04.24
		|
		|УПОРЯДОЧИТЬ ПО
		|	Номенклатура,
		|	Свойство
		|ИТОГИ ПО
		|	Номенклатура
		|АВТОУПОРЯДОЧИВАНИЕ";
	
	//Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.УстановитьПараметр("Товары", Объект.Товары.Выгрузить() );
	//+++ БФ Бобнев К.С. 09.04.24
	Запрос.УстановитьПараметр("ДатаСреза",		Объект.СсылкаНаОбъект.Дата);
	Запрос.УстановитьПараметр("ВидЦенОптовый", 	Объект.ТипЦенОптовая);
	Запрос.УстановитьПараметр("ВидЦенРозничный",Объект.ТипЦенРозничная);
	//--- БФ Бобнев К.С. 09.04.24
	//Запрос.УстановитьПараметр("Объекты", Объект.СписокОбъектов);
	результат = Запрос.Выполнить();
	
	Возврат результат.Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
	
КонецФункции


Функция УбратьПустыеСтроки(текст)
	
	фыв = новый ТекстовыйДокумент;
	фыв.УстановитьТекст(текст);
	
	размер = фыв.КоличествоСтрок();
	
	Для а=0 По размер-1 Цикл
		поз = размер - а;
		строка = сокрЛП(фыв.ПолучитьСтроку(поз));
		Если строка = "" Тогда
			фыв.УдалитьСтроку(поз);
		КонецЕсли;
	КонецЦикла;
//	
	возврат фыв.ПолучитьТекст();
КонецФункции // УбратьПустыеСтроки()

Функция ПолучитьКартинкуШтрихкода(ВнешняяКомпонента, ПараметрыШтрихкода) Экспорт
	
	Если ВнешняяКомпонента = Неопределено Тогда
		ВызватьИсключение НСтр("ru = 'Ошибка подключения внешней компоненты печати штрихкода.'");
	КонецЕсли;
	
	// Зададим размер формируемой картинки.
	ВнешняяКомпонента.Ширина = Окр(ПараметрыШтрихкода.Ширина);
	ВнешняяКомпонента.Высота = Окр(ПараметрыШтрихкода.Высота);
	ВнешняяКомпонента.АвтоТип = Ложь;
	
	ШтрихкодВрем = Строка(ПараметрыШтрихкода.Штрихкод); // Преобразуем явно в строку.
	
	Если ПараметрыШтрихкода.ТипКода = 99 Тогда
		ТипШтрихкодаВрем = ОпределитьТипШтрихкода(ШтрихкодВрем);
		Если ТипШтрихкодаВрем = "EAN8" Тогда
			ВнешняяКомпонента.ТипКода = 0;
		ИначеЕсли ТипШтрихкодаВрем = "EAN13" Тогда
			ВнешняяКомпонента.ТипКода = 1;
			// Если код содержит контрольный символ, обязательно указываем.
			ВнешняяКомпонента.СодержитКС = СтрДлина(ШтрихкодВрем) = 13;
		ИначеЕсли ТипШтрихкодаВрем = "EAN128" Тогда
			ВнешняяКомпонента.ТипКода = 2;
		ИначеЕсли ТипШтрихкодаВрем = "CODE39" Тогда
			ВнешняяКомпонента.ТипКода = 3;
		ИначеЕсли ТипШтрихкодаВрем = "CODE128" Тогда
			ВнешняяКомпонента.ТипКода = 4;
		ИначеЕсли ТипШтрихкодаВрем = "ITF14" Тогда
			ВнешняяКомпонента.ТипКода = 11;
		ИначеЕсли ТипШтрихкодаВрем = "QR" Тогда
			ВнешняяКомпонента.ТипКода = 16;
		ИначеЕсли ТипШтрихкодаВрем = "EAN13Addon2" Тогда
			ВнешняяКомпонента.ТипКода = 14;
		ИначеЕсли ТипШтрихкодаВрем = "EAN13Addon5" Тогда
			ВнешняяКомпонента.ТипКода = 15;
		Иначе
			ВнешняяКомпонента.АвтоТип = Истина;
		КонецЕсли;
	Иначе
		ВнешняяКомпонента.АвтоТип = Ложь;
		ВнешняяКомпонента.ТипКода = ПараметрыШтрихкода.ТипКода;
	КонецЕсли;
	
	Если ПараметрыШтрихкода.Свойство("ПрозрачныйФон") Тогда
		ВнешняяКомпонента.ПрозрачныйФон = ПараметрыШтрихкода.ПрозрачныйФон;
	КонецЕсли;
	
	Если ПараметрыШтрихкода.Свойство("ТипВходныхДанных") Тогда
		ВнешняяКомпонента.ТипВходныхДанных = ПараметрыШтрихкода.ТипВходныхДанных;
	КонецЕсли;
	
	Если ПараметрыШтрихкода.Свойство("GS1DatabarКоличествоСтрок") Тогда
		ВнешняяКомпонента.GS1DatabarКоличествоСтрок = ПараметрыШтрихкода.GS1DatabarКоличествоСтрок;
	КонецЕсли;
	
	ВнешняяКомпонента.ОтображатьТекст = ПараметрыШтрихкода.ОтображатьТекст;
	// Формируем картинку штрихкода.
	ВнешняяКомпонента.ЗначениеКода = ШтрихкодВрем;
	// Угол поворота штрихкода.
	ВнешняяКомпонента.УголПоворота = ?(ПараметрыШтрихкода.Свойство("УголПоворота"), ПараметрыШтрихкода.УголПоворота, 0);
	// Уровень коррекции QR кода (L=0, M=1, Q=2, H=3).
	ВнешняяКомпонента.УровеньКоррекцииQR = ?(ПараметрыШтрихкода.Свойство("УровеньКоррекцииQR"), ПараметрыШтрихкода.УровеньКоррекцииQR, 1);
	
	// Для обеспечения совместимости с предыдущими версиями БПО.
	Если Не ПараметрыШтрихкода.Свойство("Масштабировать")
		Или (ПараметрыШтрихкода.Свойство("Масштабировать") И ПараметрыШтрихкода.Масштабировать) Тогда
		
		Если Не ПараметрыШтрихкода.Свойство("СохранятьПропорции")
				Или (ПараметрыШтрихкода.Свойство("СохранятьПропорции") И Не ПараметрыШтрихкода.СохранятьПропорции) Тогда
			
			// Если установленная нами ширина меньше минимально допустимой для этого штрихкода.
			Если ВнешняяКомпонента.Ширина < ВнешняяКомпонента.МинимальнаяШиринаКода Тогда
				ВнешняяКомпонента.Ширина = ВнешняяКомпонента.МинимальнаяШиринаКода;
			КонецЕсли;
			
			// Если установленная нами высота меньше минимально допустимой для этого штрихкода.
			Если ВнешняяКомпонента.Высота < ВнешняяКомпонента.МинимальнаяВысотаКода Тогда
				ВнешняяКомпонента.Высота = ВнешняяКомпонента.МинимальнаяВысотаКода;
			КонецЕсли;
			
		ИначеЕсли ПараметрыШтрихкода.Свойство("СохранятьПропорции") И ПараметрыШтрихкода.СохранятьПропорции Тогда
			
			Пока ВнешняяКомпонента.Ширина < ВнешняяКомпонента.МинимальнаяШиринаКода 
				Или ВнешняяКомпонента.Высота < ВнешняяКомпонента.МинимальнаяВысотаКода Цикл
				
				// Если установленная нами ширина меньше минимально допустимой для этого штрихкода.
				Если ВнешняяКомпонента.Ширина < ВнешняяКомпонента.МинимальнаяШиринаКода Тогда
					ВнешняяКомпонента.Ширина = ВнешняяКомпонента.МинимальнаяШиринаКода;
					ВнешняяКомпонента.Высота = (ВнешняяКомпонента.МинимальнаяШиринаКода / Окр(ПараметрыШтрихкода.Ширина)) * Окр(ПараметрыШтрихкода.Высота);
				КонецЕсли;
				
				// Если установленная нами высота меньше минимально допустимой для этого штрихкода.
				Если ВнешняяКомпонента.Высота < ВнешняяКомпонента.МинимальнаяВысотаКода Тогда
					ВнешняяКомпонента.Высота = ВнешняяКомпонента.МинимальнаяВысотаКода;
					ВнешняяКомпонента.Ширина = (ВнешняяКомпонента.МинимальнаяВысотаКода / Окр(ПараметрыШтрихкода.Высота)) * Окр(ПараметрыШтрихкода.Ширина);
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЕсли;
	КонецЕсли;
	
	// ВертикальноеВыравниваниеКода: 1 - по верхнему краю, 2 - по центру, 3 - по нижнему краю.
	Если ПараметрыШтрихкода.Свойство("ВертикальноеВыравнивание") И (ПараметрыШтрихкода.ВертикальноеВыравнивание > 0) Тогда
		ВнешняяКомпонента.ВертикальноеВыравниваниеКода = ПараметрыШтрихкода.ВертикальноеВыравнивание;
	Иначе
		ВнешняяКомпонента.ВертикальноеВыравниваниеКода = 2;	
	КонецЕсли;
	
	Если ПараметрыШтрихкода.Свойство("РазмерШрифта") И (ПараметрыШтрихкода.РазмерШрифта > 0) 
		И (ПараметрыШтрихкода.ОтображатьТекст) И (ВнешняяКомпонента.РазмерШрифта <> ПараметрыШтрихкода.РазмерШрифта) Тогда
		ВнешняяКомпонента.РазмерШрифта = ПараметрыШтрихкода.РазмерШрифта;
	КонецЕсли;
	
	Если ПараметрыШтрихкода.Свойство("РазмерШрифта") И ПараметрыШтрихкода.РазмерШрифта > 0
		И ПараметрыШтрихкода.Свойство("МонохромныйШрифт") Тогда
		
		Если ПараметрыШтрихкода.МонохромныйШрифт Тогда
			ВнешняяКомпонента.МаксимальныйРазмерШрифтаДляПринтеровНизкогоРазрешения = ПараметрыШтрихкода.РазмерШрифта + 1;
		Иначе
			ВнешняяКомпонента.МаксимальныйРазмерШрифтаДляПринтеровНизкогоРазрешения = -1;
		КонецЕсли;
		
	КонецЕсли;
	
	// Сформируем картинку
	ДвоичныеДанныеКартинки = ВнешняяКомпонента.ПолучитьШтрихкод();
	
	// Если картинка сформировалась.
	Если ДвоичныеДанныеКартинки <> Неопределено Тогда
		// Формируем из двоичных данных.
		Возврат Новый Картинка(ДвоичныеДанныеКартинки);
	КонецЕсли;
	
	Возврат Неопределено;

КонецФункции

Функция ПодключитьВнешнююКомпонентуПечатиШтрихкода() Экспорт
	
	//ПодключениеВыполнено = ПодключитьВнешнююКомпоненту(ПоместитьВоВременноеХранилище(ПолучитьМакет("КомпонентаПечатиШтрихкодов")), "КартинкаШтрихкода", ТипВнешнейКомпоненты.COM);
	//ПодключениеВыполнено = ПодключитьВнешнююКомпоненту(ПоместитьВоВременноеХранилище(ПолучитьМакет("КомпонентаПечатиШтрихкодов_БП")), "КартинкаШтрихкода", ТипВнешнейКомпоненты.COM);
	ПодключениеВыполнено = ПодключитьВнешнююКомпоненту(ПоместитьВоВременноеХранилище(Обработки.гф_ПечатьЭтикетокГС1.ПолучитьМакет("КомпонентаПечатиШтрихкодов_БПО")), "КартинкаШтрихкода", ТипВнешнейКомпоненты.COM);
	
	// Создадим объект внешней компоненты.
	Если ПодключениеВыполнено Тогда
		ВнешняяКомпонента = Новый("AddIn.КартинкаШтрихкода.Barcode");
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
	// Если нет возможности рисовать.
	Если НЕ ВнешняяКомпонента.ГрафикаУстановлена Тогда
		// То картинку сформировать не сможем.
		Возврат Неопределено;
	Иначе
		// Установим основные параметры компоненты.
		ВнешняяКомпонента.РазмерШрифта = 12;
		ВнешняяКомпонента.ВидимостьКС = Ложь;
		ВнешняяКомпонента.ОтображатьТекст = Ложь;
		ВнешняяКомпонента.ПрозрачныйФон = Истина;
		ВнешняяКомпонента.Высота = 120;
		ВнешняяКомпонента.Ширина = 120;
		ВнешняяКомпонента.Пропорции = "1:1";
		ВнешняяКомпонента.РазделителиКода = 29;
		Возврат ВнешняяКомпонента;
	КонецЕсли;
	
КонецФункции

Функция ОпределитьТипШтрихкода(Штрихкод) Экспорт
	
	Возврат МенеджерОборудованияКлиентСервер.ОпределитьТипШтрихкода(Штрихкод);
	
КонецФункции

//&НаКлиенте
Процедура ЗаполнитьТабличнуюЧасть(Спрашивать = Истина) Экспорт
	
	//ТекстВопроса = "";
	//ЗапроситьДанные = Ложь;
	//
	//// если нет ни одного отбора, не надо ничего выбирать
	//Если Объект.Контрагент.Пустая() И Объект.СписокОбъектов.Количество() = 0 И Объект.Сезон = 0 Тогда 
	//	ЗапроситьДанные = Ложь; 
	//	ТекстВопроса = "Данные табличной части будут очищены! Продолжить?";
	//КонецЕсли;
	//
	//Если Спрашивать и Не ОчищатьТабличнуюЧасть(Объект, "Товары", ТекстВопроса) Тогда
	//	Возврат
	//КонецЕсли;
	//
	//Если Не ЗапроситьДанные Тогда
	//	Возврат
	//КонецЕсли;
	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	а.Номенклатура.Артикул КАК АртикулУпаковки,
		|	а.Номенклатура КАК Номенклатура,
		|	а.Характеристика КАК Характеристика,
		|	а.Номенклатура.СтранаПроисхождения КАК СтранаПроисхождения,
		|	СУММА(а.Количество) КАК Количество
		|ПОМЕСТИТЬ выборка
		|ИЗ
		|	Документ.ПеремещениеТоваров.Товары КАК а
		|ГДЕ
		|	(&НеИспользоватьДокументы
		|			ИЛИ а.Ссылка В (&СписокДокументов))
		|	И (&НеИспользоватьСезон
		|			ИЛИ ПОДСТРОКА(а.Номенклатура.Артикул, 11, 2) = &Сезон)
		|
		|СГРУППИРОВАТЬ ПО
		|	а.Номенклатура,
		|	а.Номенклатура.Артикул,
		|	а.Характеристика,
		|	а.Номенклатура.СтранаПроисхождения
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ИСТИНА КАК Пометка,
		|	а.АртикулУпаковки КАК АртикулУпаковки,
		|	а.Номенклатура КАК Упаковка,
		|	а.АртикулУпаковки КАК Артикул,
		|	а.Номенклатура КАК Номенклатура,
		|	а.Характеристика КАК Характеристика,
		|	а.СтранаПроисхождения КАК СтранаПроисхождения,
		|	СУММА(а.Количество) КАК КоличествоБазЕдиниц,
		|	СУММА(а.Количество) КАК КоличествоЭтикеток
		|ПОМЕСТИТЬ некомплекты
		|ИЗ
		|	выборка КАК а
		|
		|СГРУППИРОВАТЬ ПО
		|	а.АртикулУпаковки,
		|	а.Номенклатура,
		|	а.СтранаПроисхождения,
		|	а.Характеристика,
		|	а.АртикулУпаковки,
		|	а.Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	некомплекты.Пометка КАК Пометка,
		|	некомплекты.АртикулУпаковки КАК АртикулУпаковки,
		|	некомплекты.Упаковка КАК Упаковка,
		|	некомплекты.Артикул КАК Артикул,
		|	некомплекты.Номенклатура КАК Номенклатура,
		|	некомплекты.Характеристика КАК Характеристика,
		|	некомплекты.СтранаПроисхождения КАК СтранаПроисхождения,
		|	НЕОПРЕДЕЛЕНО КАК ЕдИзмБазовая,
		|	НЕОПРЕДЕЛЕНО КАК КМ,
		|	некомплекты.КоличествоБазЕдиниц КАК КоличествоБазЕдиниц,
		|	некомплекты.КоличествоЭтикеток КАК КоличествоЭтикеток
		|ИЗ
		|	некомплекты КАК некомплекты
		|
		|УПОРЯДОЧИТЬ ПО
		|	АртикулУпаковки,
		|	Артикул
		|АВТОУПОРЯДОЧИВАНИЕ";
	
	Запрос.УстановитьПараметр("НеИспользоватьДокументы", Объект.СписокОбъектов.Количество() = 0);
	Запрос.УстановитьПараметр("СписокДокументов", Объект.СписокОбъектов);
	Запрос.УстановитьПараметр("НеИспользоватьКонтрагента", Объект.Контрагент.Пустая());
	Запрос.УстановитьПараметр("Контрагент", Объект.Контрагент);
	Запрос.УстановитьПараметр("НеИспользоватьСезон", Объект.Сезон = 0);
	Запрос.УстановитьПараметр("Сезон", Строка(Объект.Сезон));
	
	Объект.Товары.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////////////////////////
Функция ОчищатьТабличнуюЧасть(Объект, ТЧ, ТекстВопроса = "") Экспорт
	
	Если Объект[ТЧ].Количество() > 0 Тогда

		//Если ТекстВопроса = "" Тогда ТекстВопроса = "Перед заполнением табличная часть будет очищена. Заполнить?" КонецЕсли;
		
		//Ответ = Вопрос(ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да, Объект.Метаданные().Имя);
		
		//Если Ответ = КодВозвратаДиалога.Да Тогда
		//	
		//	Объект[ТЧ].Очистить();
			Возврат Истина;
			
		//Иначе
		//	
		//	Возврат Ложь;
		//	
		//КонецЕсли; 
	
	КонецЕсли;

	Возврат Истина;
	
КонецФункции

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Объект.СсылкаНаОбъект = ЭтотОбъект.Параметры.ОбъектыПечати[0].Ссылка;
	Объект.Организация = ЭтотОбъект.Параметры.ОбъектыПечати[0].Организация;
	Объект.ВзятьАдресОрганизации = "ВзятьАдресОрганизции" ;
	СсылкаНаОбъектПриИзмененииНаСервере();
	ОрганизацияПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура СсылкаНаОбъектПриИзменении(Элемент)
	СсылкаНаОбъектПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура СсылкаНаОбъектПриИзмененииНаСервере()
	Объект.СписокОбъектов.Очистить();
	Если ЗначениеЗаполнено(Объект.СсылкаНаОбъект) Тогда
		
		Объект.СписокОбъектов.Добавить(Объект.СсылкаНаОбъект);
		//МассивОбъектов = Новый Массив;
		//МассивОбъектов.Добавить(Объект.СписокОбъектов[0].Значение);
		
		ЗаполнитьТабличнуюЧасть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьВсе(Команда)
	УстановитьПометку(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсе(Команда)
	УстановитьПометку(Истина);
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПометку(Пометка)
	Для каждого Стр Из Объект.Товары Цикл
		ИД = Стр.ПолучитьИдентификатор();
		Если Элементы.Товары.ПроверитьСтроку(ИД) Тогда
			Стр.Пометка = Пометка;
		КонецЕсли;
	КонецЦикла; 
КонецПроцедуры

ВзятьАдресОрганизации = Истина;
НаПринтер = Ложь;
