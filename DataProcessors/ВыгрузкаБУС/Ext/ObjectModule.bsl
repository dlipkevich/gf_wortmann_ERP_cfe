﻿
//-Идентификаторы свойств  

Функция ИдентификаторСвойства_B2B_Предзаказ() Экспорт
	
	Возврат "B2B_Предзаказ";
	
КонецФункции 

Функция ИдентификаторСвойства_B2B_Каталог() Экспорт
	
	Возврат "B2B_Каталог";
	
КонецФункции

Функция ИдентификаторСвойства_B2B_КонтрагентВыгружен() Экспорт
	
	Возврат "B2B_КонтрагентВыгружен";
	
КонецФункции

Функция ИдентификаторСвойства_B2B_НомерЗаказа() Экспорт
	
	Возврат "B2B_НомерЗаказа";
	
КонецФункции

Функция ИдентификаторСвойства_B2B_Загружен() Экспорт
	
	Возврат "B2B_Загружен";
	
КонецФункции

Функция ИдентификаторСвойства_B2B_ДатаОтправки_Спец1() Экспорт
	
	Возврат "B2B_ДатаОтправки_Спец1";
	
КонецФункции

Функция ИдентификаторСвойства_B2B_ДатаОтправки_Спец2() Экспорт
	
	Возврат "B2B_ДатаОтправки_Спец2";
	
КонецФункции

Функция ИдентификаторСвойства_B2B_ДатаОтправкиСчет() Экспорт
	
	Возврат "B2B_ДатаОтправкиСчет";
	
КонецФункции 

Функция ИдентификаторСвойства_B2B_ИД_КонтактногоЛица() Экспорт
	
	Возврат "B2B_ИД_КонтактногоЛица";
	
КонецФункции

Функция ИдентификаторСвойства_B2B_FilterSizeBox() Экспорт
	
	Возврат "B2B_FilterSizeBox";
	
КонецФункции

Функция ИдентификаторСвойства_B2B_Size() Экспорт
	
	Возврат "B2B_Size";
	
КонецФункции

Функция ИдентификаторСвойства_B2B_РазмерныйРяд() Экспорт
	
	Возврат "B2B_РазмерныйРяд";
	
КонецФункции

//Идентификаторы свойств-

Функция ПолучитьМайлИзКонтактнойИнформации(Объект) Экспорт 

	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Объект", Объект);
	Запрос.УстановитьПараметр("Тип"   , Перечисления.ТипыКонтактнойИнформации.АдресЭлектроннойПочты);
	Запрос.УстановитьПараметр("Вид"   , Справочники.ВидыКонтактнойИнформации.АдресЭлектроннойПочтыКонтрагентаДляОбменаДокументами);
	
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	|	КонтактнаяИнформация.Представление
	|ИЗ
	|	РегистрСведений.КонтактнаяИнформация КАК КонтактнаяИнформация
	|ГДЕ
	|	КонтактнаяИнформация.Объект = &Объект
	|	И КонтактнаяИнформация.Тип = &Тип
	|	И КонтактнаяИнформация.Вид = &Вид";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат "";
	Иначе
		Возврат РезультатЗапроса.Выгрузить()[0].Представление;
	КонецЕсли;

КонецФункции

Функция ПолучитьЗначениеСвойства(Объект, Свойство)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ЗначенияСвойствОбъектов.Значение
	|ИЗ
	|	РегистрСведений.ЗначенияСвойствОбъектов КАК ЗначенияСвойствОбъектов
	|ГДЕ
	|	ЗначенияСвойствОбъектов.Свойство = &Свойство
	|	И ЗначенияСвойствОбъектов.Объект = &Объект";
	
	Запрос.УстановитьПараметр("Объект", Объект);
	Запрос.УстановитьПараметр("Свойство", Свойство);
	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Выборка.Следующий();
	
	Возврат Выборка.Значение;
	
КонецФункции

Функция ЗаписатьЗначениеСвойства(Объект,СтруктураСвойства) Экспорт    
    НаборЗаписейЗначенияСвойств = РегистрыСведений.ДополнительныеСведения.СоздатьНаборЗаписей();
    Если ЗначениеЗаполнено(СтруктураСвойства.Значение) Тогда
        Запись = НаборЗаписейЗначенияСвойств.Добавить();
        Запись.Объект   = Объект.Ссылка;
        Свойство=СтруктураСвойства.Свойство;
        Запись.Свойство = Свойство.Ссылка;
        Запись.Значение = СтруктураСвойства.Значение;
    КонецЕсли;
    
    НаборЗаписейЗначенияСвойств.Отбор.Объект.Установить(Объект.Ссылка);
    НаборЗаписейЗначенияСвойств.Отбор.Свойство.Установить(Свойство); //.Ссылка
    Попытка
        НаборЗаписейЗначенияСвойств.Записать();
    Исключение
        Возврат Ложь;
    КонецПопытки;
    Возврат Истина;    
КонецФункции

Процедура глДополнитьТекст(ИтоговыйТекст,ДопТекст,Разделитель=" И ") Экспорт
	Если СокрЛП(ДопТекст)="" Тогда
		Возврат;
	КонецЕсли; 
	
	ИтоговыйТекст=ИтоговыйТекст+?(ИтоговыйТекст="","",Разделитель)+СокрЛП(ДопТекст);
КонецПроцедуры
//1 Создать свойства у заказа при открытии "B2B_Загружен", "B2B_НомерЗаказа"  если не созданы
//2 Решить что делать со статусами заказов Результат.Вставить("STATUS", СокрЛП(Справочники.B2B_СтатусыЗаказов.Новый.УникальныйИдентификатор()));
